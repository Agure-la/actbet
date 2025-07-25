defmodule Actbet.Games do
  import Ecto.Query, warn: false
  alias Actbet.Repo
  alias Actbet.Games.Game
  alias Actbet.Games.League

defp parse_start_time(%{"start_time" => start_time}) when is_binary(start_time) do
  case NaiveDateTime.from_iso8601(start_time) do
    {:ok, dt} -> {:ok, dt}
    _ -> {:error, "Invalid start_time format"}
  end
end

defp game_exists_today?(team, %NaiveDateTime{} = start_time, sport) do
  date = NaiveDateTime.to_date(start_time)

  from(g in Game,
    where:
      (g.home_team == ^team or g.away_team == ^team) and
      fragment("date(?)", g.start_time) == ^date and
      g.sport == ^sport
  )
  |> Repo.exists?()
end

def create_game(attrs) do
  with {:ok, naive_datetime} <- parse_start_time(attrs),
       sport <- attrs["sport"],
       false <- game_exists_today?(attrs["home_team"], naive_datetime, sport),
       false <- game_exists_today?(attrs["away_team"], naive_datetime, sport),
       league_id when not is_nil(league_id) <- attrs["league_id"],
       %League{} <- Repo.get(League, league_id) do

    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()

  else
    {:error, reason} ->
      {:error, reason}

    true ->
      {:error, "One of the teams already has a game on this day"}

    nil ->
      {:error, "League ID is required"}

    %League{} = _league ->
      # shouldn't hit here, but for clarity
      {:error, "Unexpected case"}

    _ ->
      {:error, "League not available"}
  end
end


  def list_games(params \\ %{}) do
  query =
    Game
    |> where([g], g.status == "active")
    |> order_by(asc: :start_time)

  Repo.paginate(query, params)
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

  def list_games_by_league(league_id, params \\ %{}) do
  Game
  |> where([g], g.league_id == ^league_id and g.status == "active")
  |> order_by(asc: :start_time)
  |> Actbet.Repo.paginate(params)
end


end
