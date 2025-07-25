defmodule Actbet.Leagues do
  import Ecto.Query, warn: false
  alias Actbet.Repo
  alias Actbet.Games.League

  def create_league(attrs \\ %{}) do
  name = Map.get(attrs, "name") || Map.get(attrs, :name)
  country = Map.get(attrs, "country") || Map.get(attrs, :country)

  case Repo.get_by(League, name: name, country: country) do
    nil ->
      %League{}
      |> League.changeset(attrs)
      |> Repo.insert()

    _league ->
      {:error, "League already exists"}
  end
end

  def list_leagues(params \\ %{}) do
  League
  |> Repo.paginate(params)
end

def get_league!(id), do: Repo.get!(League, id)

def update_league(%League{} = league, attrs) do
  league
  |> League.changeset(attrs)
  |> Repo.update()
end

def delete_league(%League{} = league) do
  Repo.delete(league)
end

def list_leagues_by_country(country) do
  from(l in League, where: l.country == ^country)
  |> Repo.all()
end

end
