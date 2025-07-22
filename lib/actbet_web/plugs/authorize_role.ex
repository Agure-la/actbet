defmodule ActbetWeb.Plugs.AuthorizeRole do
  import Plug.Conn
  import Phoenix.Controller

  def init(required_roles), do: required_roles

  def call(conn, required_roles) do
    current_user = conn.assigns[:current_user]

    if current_user && current_user.role.name in required_roles do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Forbidden"})
      |> halt()
    end
  end
end
