defmodule Actbet.Repo.Migrations.AddBetOddsAndPossibleWin do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :bet_odds, :map
    end

    alter table(:bets) do
      add :possible_win, :decimal
    end
  end
end
