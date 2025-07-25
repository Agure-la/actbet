defmodule Actbet.Repo.Migrations.AddSportToGames do
  use Ecto.Migration

  def change do
  alter table(:games) do
      add :sport, :string, null: false, default: "football"
    end
  end
end
