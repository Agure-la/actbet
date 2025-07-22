defmodule Actbet.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :user_id, :amount, :status, :possible_win, :won_amount, :inserted_at, :updated_at]}
  schema "bets" do
    field :status, :string, default: "placed"
    field :amount, :decimal
    field :won_amount, :decimal
    field :possible_win, :decimal

    belongs_to :user, Actbet.Accounts.User, type: :integer
    has_many :selections, Actbet.Bets.BetSelection, foreign_key: :bet_id

    timestamps()
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:user_id, :status, :amount, :won_amount, :possible_win])
    |> validate_required([:user_id, :status, :amount])
    |> validate_inclusion(:status, ["placed", "cancelled", "won", "lost"])
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:selections, required: true)
  end
end
