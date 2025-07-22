defmodule Actbet.Repo.Migrations.CreateBetSelections do
  use Ecto.Migration

  def change do
    create table(:bet_selections) do
      add :bet_id, references(:bets, on_delete: :delete_all)
      add :game_id, references(:games, on_delete: :delete_all)
      add :choice, :string
      add :odd, :float

      timestamps()
    end

    create index(:bet_selections, [:bet_id])
    create index(:bet_selections, [:game_id])
  end
end
