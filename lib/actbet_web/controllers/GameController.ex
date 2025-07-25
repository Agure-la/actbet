
defmodule ActbetWeb.GameController do
  use ActbetWeb, :controller

  alias Actbet.Games

  def create(conn, %{"game" => game_params}) do
    case Games.create_game(game_params) do
      {:ok, game} -> json(conn, %{message: "Game created", data: game})
      {:error, changeset} -> conn |> put_status(:bad_request) |> json(%{errors: changeset})
    end
  end

  def index(conn, params) do
  page = Games.list_games(params)

  json(conn, %{
    data: page.entries,
    pagination: %{
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    }
  })
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

  def update_result(conn, %{"id" => id, "result" => result}) do
  case Games.update_game_result(id, result) do
    {:ok, game} ->
      conn
      |> put_status(:ok)
      |> json(%{
        id: game.id,
        status: game.status,
        result: game.result,
        start_time: game.start_time
        # Add other fields you want to include
      })

    {:error, reason} ->
      conn
      |> put_status(:bad_request)
      |> json(%{error: reason})
  end
end

def games_by_league(conn, %{"league_id" => league_id} = params) do
  page = Games.list_games_by_league(league_id, params)

  json(conn, %{
    data: page.entries,
    pagination: %{
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    }
  })
end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, val}, acc ->
        String.replace(acc, "%{#{key}}", to_string(val))
      end)
    end)
  end
end
