defmodule ActbetWeb.LeagueController do
  use ActbetWeb, :controller

  alias Actbet.Leagues

   def list_by_country(conn, %{"country" => country}) do
    leagues = Leagues.list_leagues_by_country(country)
    render(conn, :index, leagues: leagues)
  end


def create(conn, %{"league" => league_params}) do
  with {:ok, league} <- Leagues.create_league(league_params) do
    json(conn, league)
  end
end

def show(conn, %{"id" => id}) do
  league = Leagues.get_league!(id)
  json(conn, league)
end

def update(conn, %{"id" => id, "league" => league_params}) do
  league = Leagues.get_league!(id)

  with {:ok, updated} <- Games.update_league(league, league_params) do
    json(conn, updated)
  end
end

def delete(conn, %{"id" => id}) do
  league = Leagues.get_league!(id)

  with {:ok, _} <- Games.delete_league(league) do
    send_resp(conn, :no_content, "")
  end
end

def list_by_country(conn, %{"country" => country}) do
  leagues = Leagues.list_leagues_by_country(country)
  render(conn, :index, leagues: leagues)
end


end
