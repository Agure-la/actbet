defmodule ActbetWeb.AuthController do
  use ActbetWeb, :controller
  alias Actbet.Accounts

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        json(conn, %{message: "User registered successfully", user: user})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def login(conn, %{"msisdn" => msisdn, "password" => password}) do
    case Accounts.login_user(msisdn, password) do
      {:ok, user} ->
        token = Phoenix.Token.sign(ActbetWeb.Endpoint, "user_auth", user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          message: "Login successful",
          token: token,
          user: %{
            id: user.id,
            msisdn: user.msisdn,
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email_address
          }
        })

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: message})
    end
  end

  defp generate_token(id) do
    # Replace with Guardian or your own token generator
    Phoenix.Token.sign(ActbetWeb.Endpoint, "user_auth", id)
  end

  def index(conn, _params) do
    users = Accounts.list_users_with_bets()
    json(conn, users)
  end

  def total_profit(conn, _params) do
    profit = Accounts.total_profit_from_losses() || 0
    json(conn, %{total_profit_from_losses: profit})
  end

  def update_role(conn, %{"id" => user_id, "new_role" => role_name}) do
    case Accounts.update_user_role(user_id, role_name) do
      {:ok, updated_user} ->
        json(conn, %{message: "Role updated", user: updated_user})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid role or user", details: changeset_errors(changeset)})

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Something went wrong"})
    end
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "User or role not found"})
  end

  def soft_delete(conn, %{"id" => user_id}) do
    case Accounts.soft_delete_user(user_id) do
      {:ok, _} ->
        json(conn, %{message: "User soft-deleted successfully"})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "User not found"})
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, val}, acc ->
        String.replace(acc, "%{#{key}}", to_string(val))
      end)
    end)
  end
end
