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

def place_bet(user_id, attrs) do
  case Repo.get(User, user_id) do
    nil ->
      Logger.error("User with ID #{user_id} not found")
      {:error, "User not found"}

    %User{} ->
      selections = attrs["selections"] || attrs[:selections]

      with true <- is_list(selections),
           true <- no_duplicate_games?(selections),
           %Decimal{} = amount <- parse_decimal(attrs["amount"] || attrs[:amount]),
           {:ok, enriched_selections, total_odds} <- enrich_and_calculate_odds(selections),
           possible_win <- Decimal.mult(amount, Decimal.from_float(total_odds)) do

        bet_attrs =
          attrs
          |> Map.put("user_id", user_id)
          |> Map.put("status", "placed")
          |> Map.put("possible_win", possible_win)

        Repo.transaction(fn ->
          Logger.debug("Attempting to insert bet with attrs: #{inspect(bet_attrs)}")

          case %Bet{} |> Bet.changeset(bet_attrs) |> Repo.insert() do
            {:ok, bet} ->
              Logger.info("Successfully inserted bet with ID: #{bet.id}")

              # Add bet_id to each selection
              selections_with_bet_id =
  enriched_selections
  |> Enum.map(fn sel ->
    updated =
      sel
      |> Map.from_struct()  # Converts struct to plain map (safe for Map.put)
      |> Map.put("bet_id", bet.id)

    Logger.debug("Prepared selection for insert: #{inspect(updated)}")
    updated
  end)

              # Insert each selection
              selections_result =
                Enum.map(selections_with_bet_id, fn sel_attrs ->
                  Logger.debug("Inserting selection: #{inspect(sel_attrs)}")

                  case %BetSelection{}
                       |> BetSelection.changeset(sel_attrs)
                       |> Repo.insert() do
                    {:ok, selection} ->
                      Logger.info("Inserted selection with ID: #{selection.id}")
                      {:ok, selection}

                    {:error, changeset} = error ->
                      Logger.error("Failed to insert selection: #{inspect(changeset.errors)}")
                      error
                  end
                end)

              # Rollback if any failed
              case Enum.find(selections_result, fn
                     {:error, _} -> true
                     _ -> false
                   end) do
                nil ->
                  Logger.info("All selections inserted successfully")
                  {:ok, Repo.preload(bet, :selections)}

                {:error, failed_changeset} ->
                  Logger.error("Rolling back due to selection error: #{inspect(failed_changeset.errors)}")
                  Repo.rollback(failed_changeset)
              end

            {:error, bet_changeset} ->
              Logger.error("Failed to insert bet: #{inspect(bet_changeset.errors)}")
              Repo.rollback(bet_changeset)
          end
        end)
      else
        false ->
          Logger.error("Duplicate games found in selections: #{inspect(selections)}")
          {:error, "Duplicate games in selections are not allowed"}

        nil ->
          Logger.error("Invalid selections or amount")
          {:error, "Invalid selections or amount"}

        {:error, msg} ->
          Logger.error("Error from enrich or validation: #{inspect(msg)}")
          {:error, msg}

        other ->
          Logger.error("Unexpected error: #{inspect(other)}")
          {:error, "Failed to place bet"}
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
