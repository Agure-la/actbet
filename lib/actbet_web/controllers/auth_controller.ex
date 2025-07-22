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
end
