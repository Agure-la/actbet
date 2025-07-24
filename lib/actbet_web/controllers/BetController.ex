defmodule ActbetWeb.BetController do
  use ActbetWeb, :controller
  alias Actbet.Bets
  alias Actbet.Repo

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

  def cancel(conn, %{"id" => bet_id}) do
    case Bets.cancel_bet(bet_id) do
      {:ok, bet} ->
        json(conn, %{message: "Bet cancelled successfully", bet: bet})

      {:error, "Bet not found"} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Bet not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to cancel bet", details: changeset_errors(changeset)})
    end
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, val}, acc -> String.replace(acc, "%{#{key}}", to_string(val)) end)
    end)
  end
end
