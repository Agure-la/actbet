
defmodule ActbetWeb.GameController do
  use ActbetWeb, :controller

  alias Actbet.Games

  def create(conn, %{"game" => game_params}) do
    case Games.create_game(game_params) do
      {:ok, game} -> json(conn, %{message: "Game created", data: game})
      {:error, changeset} -> conn |> put_status(:bad_request) |> json(%{errors: changeset})
    end
  end

  def index(conn, _params) do
    games = Games.list_games()
    json(conn, %{data: games})
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    json(conn, %{data: game})
  end

  def finish(conn, %{"id" => id, "result" => result}) do
    case Games.finish_game(id, result) do
      {:ok, game} -> json(conn, %{message: "Game finished", data: game})
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end
end
