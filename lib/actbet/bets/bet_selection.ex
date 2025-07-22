defmodule Actbet.Bets.BetSelection do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :bet_id, :game_id, :choice, :odd, :inserted_at, :updated_at]}
  schema "bet_selections" do
    field :game_id, :id
    field :choice, :string
    field :odd, :float

    belongs_to :bet, Actbet.Bets.Bet

    timestamps()
  end

  def changeset(selection, attrs) do
    selection
    |> cast(attrs, [:game_id, :choice, :odd, :bet_id])
    |> validate_required([:game_id, :choice, :odd, :bet_id])
  end
end
