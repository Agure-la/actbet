defmodule Actbet.Bets do
  import Ecto.Query, warn: false
  alias Actbet.Repo
  alias Actbet.Bets.Bet
  alias Actbet.Accounts.User
  alias Actbet.Games.Game

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


def place_bet(user_id, attrs) do
  case Repo.get(User, user_id) do
    nil ->
      {:error, "User not found"}

    %User{} ->
      selections = attrs["selections"] || attrs[:selections]

      with true <- is_list(selections),
           true <- no_duplicate_games?(selections),
           %Decimal{} = amount <- parse_decimal(attrs["amount"] || attrs[:amount]),
           {:ok, total_odds} <- fetch_total_odds(selections),
           possible_win <- Decimal.mult(amount, Decimal.from_float(total_odds)) do

        updated_attrs =
          attrs
          |> Map.put("user_id", user_id)
          |> Map.put("possible_win", possible_win)

        %Bet{}
        |> Bet.changeset(updated_attrs)
        |> Repo.insert()
      else
        false -> {:error, "Duplicate games in selections are not allowed"}
        nil -> {:error, "Invalid selections or amount"}
        {:error, msg} -> {:error, msg}
        _ -> {:error, "Failed to place bet"}
      end
  end
end



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
end
