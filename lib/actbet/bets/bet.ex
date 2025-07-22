defmodule Actbet.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :user_id, :game_id, :amount, :bet_choice, :inserted_at, :updated_at]}
  schema "bets" do
    field :bet_choice, :string
    field :status, :string, default: "placed"
    field :amount, :decimal
    field :won_amount, :decimal
    field :possible_win, :decimal

    belongs_to :user, Actbet.Accounts.User, type: :integer
    belongs_to :game, Actbet.Games.Game

    timestamps()
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:user_id, :game_id, :bet_choice, :status, :amount, :won_amount])
    |> validate_required([:user_id, :game_id, :bet_choice, :status, :amount])
    |> validate_inclusion(:bet_choice, ["home", "away", "draw","gg", "ng", "ov2.5","un2.5", "1x", "2x"])
    |> validate_inclusion(:status, ["placed", "cancelled", "won", "lost"])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:game_id)
  end
end
