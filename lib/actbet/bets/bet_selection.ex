defmodule Actbet.Bets.BetSelection do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :bet_id, :game_id, :choice, :inserted_at, :updated_at]}
  schema "bet_selections" do
    #field :game_id, :id
    field :choice, :string

    belongs_to :bet, Actbet.Bets.Bet
    belongs_to :game, Actbet.Games.Game

    timestamps()
  end

  def changeset(selection, attrs) do
    selection
    |> cast(attrs, [:game_id, :bet_id, :choice])
    |> validate_required([:game_id, :choice])
  end
end
