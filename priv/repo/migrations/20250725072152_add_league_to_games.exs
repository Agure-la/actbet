defmodule Actbet.Repo.Migrations.AddLeagueToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
    add :league_id, references(:leagues, on_delete: :nothing)
  end

  create index(:games, [:league_id])
  end
end
