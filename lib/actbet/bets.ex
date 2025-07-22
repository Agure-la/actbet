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

 def place_bet(user_id, attrs) do
  case Repo.get(User, user_id) do
    nil ->
      {:error, "User not found"}

    %User{} ->
      game_id = attrs["game_id"] || attrs[:game_id]
      with %Game{bet_odds: odds} = game <- Repo.get(Game, game_id),
           bet_choice when is_binary(bet_choice) <- attrs["bet_choice"] || attrs[:bet_choice],
           %Decimal{} = amount <- parse_decimal(attrs["amount"] || attrs[:amount]),
           {:ok, odd} <- fetch_odd(odds, bet_choice),
           possible_win <- Decimal.mult(amount, Decimal.from_float(odd)) do

        updated_attrs =
          attrs
          |> Map.put("user_id", user_id)
          |> Map.put("possible_win", possible_win)

        %Bet{}
        |> Bet.changeset(updated_attrs)
        |> Repo.insert()
      else
        nil -> {:error, "Invalid game selected"}
        {:error, msg} -> {:error, msg}
        _ -> {:error, "Invalid data provided"}
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
