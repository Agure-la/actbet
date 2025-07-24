defmodule Actbet.Bets do
  import Ecto.Query, warn: false
  alias Actbet.Repo
  alias Actbet.Bets.Bet
  alias Actbet.Accounts.User
  alias Actbet.Games.Game
  alias Actbet.Bets.BetSelection
  @doc """
  Places a bet for a given user and game.

  Returns {:ok, bet} or {:error, changeset}
  """

  defp parse_decimal(value) when is_binary(value), do: Decimal.parse(value) |> elem(0)
defp parse_decimal(%Decimal{} = val), do: val
defp parse_decimal(value) when is_integer(value), do: Decimal.new(value)
defp parse_decimal(value) when is_float(value), do: Decimal.from_float(value)
defp parse_decimal(_), do: nil

defp fetch_odd(nil, _), do: {:error, "No odds configured for this game"}
defp fetch_odd(odds, bet_choice) do
  case Map.get(odds, bet_choice) do
    nil -> {:error, "No odds available for #{bet_choice}"}
    odd -> {:ok, odd}
  end
end

defp no_duplicate_games?(selections) do
  game_ids = Enum.map(selections, & &1["game_id"])
  length(game_ids) == length(Enum.uniq(game_ids))
end

defp fetch_total_odds(selections) do
  selections
  |> Enum.reduce_while({:ok, 1.0}, fn %{"game_id" => game_id, "choice" => choice}, {:ok, acc} ->
    case Repo.get(Game, game_id) do
      nil ->
        {:halt, {:error, "Game #{game_id} not found"}}

      %Game{bet_odds: nil} ->
        {:halt, {:error, "No odds configured for game #{game_id}"}}

      %Game{bet_odds: odds} ->
        case Map.get(odds, choice) do
          nil -> {:halt, {:error, "No odds for #{choice} in game #{game_id}"}}
          odd -> {:cont, {:ok, acc * odd}}
        end
    end
  end)
end

defp enrich_and_calculate_odds(selections) do
  try do
    enriched =
      Enum.map(selections, fn %{"game_id" => game_id, "choice" => choice} ->
        game = Repo.get!(Actbet.Games.Game, game_id)

        case Map.get(game.bet_odds || %{}, choice) do
          nil -> throw({:error, "Invalid choice #{choice} for game #{game_id}"})
          odd -> %{game_id: game_id, choice: choice, odd: odd}
        end
      end)

    total_odds = Enum.reduce(enriched, 1.0, fn %{odd: o}, acc -> acc * o end)
    {:ok, enriched, total_odds}
  catch
    {:error, reason} -> {:error, reason}
  end
end

require Logger

defp insert_selections_async(bet_id, selections) do
  for sel <- selections do
    sel
    |> Map.put("bet_id", bet_id)
    |> normalize_keys()
    |> BetSelection.changeset(%BetSelection{})
    |> Repo.insert()
    |> case do
      {:ok, _selection} -> :ok
      {:error, cs} ->
        Logger.error("Failed to insert selection for bet #{bet_id}: #{inspect(cs.errors)}")
        :error
    end
  end
end

defp normalize_keys(map) do
  for {k, v} <- map, into: %{} do
    key = if is_binary(k), do: String.to_atom(k), else: k
    {key, v}
  end
end

defp ensure_games_not_finished(selections) do
  case Enum.find(selections, fn sel ->
         game = Repo.get(Game, sel["game_id"] || sel[:game_id])
         game && game.status == "finished"
       end) do
    nil -> :ok
    _ -> {:error, "Cannot place bet on a game that is already finished"}
  end
end

def place_bet(user_id, attrs) do
  case Repo.get(User, user_id) do
    nil -> {:error, "User not found"}

    %User{} ->
      with true <- is_list(attrs["selections"] || attrs[:selections]),
           %Decimal{} = amount <- parse_decimal(attrs["amount"] || attrs[:amount]),
           {:ok, enriched_selections, total_odds} <- enrich_and_calculate_odds(attrs["selections"]),
           :ok <- ensure_games_not_finished(enriched_selections),
           possible_win <- Decimal.mult(amount, Decimal.from_float(total_odds)),
           game_id <- extract_game_id(enriched_selections),
           true <- not is_nil(game_id) do

        bet_attrs =
          attrs
          |> Map.put("user_id", user_id)
          |> Map.put("status", "placed")
          |> Map.put("possible_win", possible_win)
          |> Map.put("game_id", game_id)

        case Repo.insert(Bet.changeset(%Bet{}, bet_attrs)) do
          {:ok, bet} ->
            Task.start(fn ->
              insert_selections_async(bet.id, enriched_selections)
            end)

            {:ok, bet}

          {:error, cs} ->
            {:error, cs}
        end
      else
        {:error, reason} -> {:error, reason}
        _ -> {:error, "Invalid data or missing selections/game info"}
      end
  end
end

defp extract_game_id([%{game_id: game_id} | _]), do: game_id
defp extract_game_id(_), do: nil

  @doc """
  Lists all bets placed by a user.
  """
  def list_user_bets(user_id) do
    Bet
    |> where([b], b.user_id == ^user_id)
    |> preload([:game])
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def cancel_bet(bet_id) do
  case Repo.get(Bet, bet_id) do
    nil ->
      {:error, Ecto.Changeset.change(%Bet{}) |> Ecto.Changeset.add_error(:bet, "not found")}

    %Bet{status: "placed"} = bet ->
      selections_with_games =
        from(bs in BetSelection,
          where: bs.bet_id == ^bet_id,
          join: g in Game, on: g.id == bs.game_id,
          preload: [game: g]
        )
        |> Repo.all()

      now = DateTime.utc_now()

      if Enum.any?(selections_with_games, fn %{game: game} ->
           DateTime.compare(game.start_time, now) != :gt
         end) do
        {:error,
         Ecto.Changeset.change(bet)
         |> Ecto.Changeset.add_error(:bet, "Cannot cancel. A game has already started.")}
      else
        bet
        |> Ecto.Changeset.change(status: "cancelled")
        |> Repo.update()
      end

    _ ->
      {:error, Ecto.Changeset.change(%Bet{}) |> Ecto.Changeset.add_error(:bet, "Only placed bets can be cancelled")}
  end
end

end
