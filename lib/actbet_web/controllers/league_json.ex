defmodule ActbetWeb.LeagueJSON do
  # Called when rendering list of leagues
  def index(%{leagues: leagues}) do
    %{data: Enum.map(leagues, &league/1)}
  end

  # Called when rendering a single league
  def show(%{league: league}) do
    %{data: league(league)}
  end

  defp league(league) do
    %{
      id: league.id,
      name: league.name,
      country: league.country
    }
  end
end
