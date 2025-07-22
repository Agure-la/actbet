defmodule ActbetWeb.BetController do
  use ActbetWeb, :controller
  alias Actbet.Bets

 def create(conn, %{"bet" => bet_params}) do
  user_id = conn.assigns.current_user.id  # assuming plug assigns current_user

  case Bets.place_bet(user_id, bet_params) do
    {:ok, bet} ->
      #  preload selections
      bet = Repo.preload(bet, :selections)

      json(conn, %{
        message: "Bet placed successfully",
        data: bet
      })

    {:error, %Ecto.Changeset{} = changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{
        errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
      })

    {:error, reason} ->
      conn
      |> put_status(:bad_request)
      |> json(%{error: reason})
  end
end



  def user_bets(conn, _params) do
    user_id = conn.assigns.current_user.id
    bets = Bets.list_user_bets(user_id)

    json(conn, %{data: bets})
  end
end
