defmodule Actbet.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
    add :home_team, :string, null: false
      add :away_team, :string, null: false
      add :start_time, :naive_datetime, null: false
      add :result, :string  #  "home_win", "away_win", "draw"

      timestamps()
    end
  end
end
