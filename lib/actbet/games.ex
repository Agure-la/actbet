defmodule Actbet.Games do
  import Ecto.Query, warn: false
  alias Actbet.Repo
  alias Actbet.Games.Game

defp parse_start_time(%{"start_time" => start_time}) when is_binary(start_time) do
  case NaiveDateTime.from_iso8601(start_time) do
    {:ok, dt} -> {:ok, dt}
    _ -> {:error, "Invalid start_time format"}
  end
end

defp game_exists_today?(team, %NaiveDateTime{} = start_time) do
  date = NaiveDateTime.to_date(start_time)

  from(g in Game,
    where:
      (g.home_team == ^team or g.away_team == ^team) and
        fragment("date(?)", g.start_time) == ^date
  )
  |> Repo.exists?()
end

def create_game(attrs) do
  with {:ok, naive_datetime} <- parse_start_time(attrs),
       false <- game_exists_today?(attrs["home_team"], naive_datetime),
       false <- game_exists_today?(attrs["away_team"], naive_datetime) do

    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()

  else
    {:error, reason} -> {:error, reason}
    true -> {:error, "One of the teams already has a game on this day"}
  end
end


  def list_games do
    Game
    |> where([g], g.status == "active")
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_game!(id), do: Repo.get!(Game, id)

  def finish_game(id, result \\ nil) do
    case Repo.get(Game, id) do
      nil -> {:error, "Game not found"}
      game ->
        game
        |> Game.changeset(%{status: "finished", result: result, end_time: DateTime.utc_now()})
        |> Repo.update()
    end
  end

  def update_game_result(game_id, result) when result in ["home", "away", "draw"] do
    
    case Repo.get(Game, game_id) do
      nil -> {:error, "Game not found"}
      game ->
        game
        |> Ecto.Changeset.change(result: result, status: "finished")
        |> Repo.update()
    end
  end
end
