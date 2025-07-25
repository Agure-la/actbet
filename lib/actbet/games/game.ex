defmodule Actbet.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :home_team, :away_team, :start_time, :status, :sport, :inserted_at, :updated_at, :bet_odds]}
  schema "games" do
    field :home_team, :string
    field :away_team, :string
    field :start_time, :naive_datetime
    field :result, :string  # "home_win", "away_win", "draw"
    field :status, :string, default: "active"  # "active", "started", "finished", "cancelled"
    field :sport, :string
    field :bet_odds, :map

    has_many :bets, Actbet.Bets.Bet

    timestamps()
  end

  defp validate_odds_map(changeset) do
  odds = get_field(changeset, :bet_odds)

  expected_keys = ~w(home away draw gg ng ov2.5 un2.5 1x 2x)

  cond do
    is_nil(odds) -> changeset

    Enum.all?(expected_keys, &Map.has_key?(odds, &1)) ->
      changeset

    true ->
      add_error(changeset, :bet_odds, "must contain all required betting choices")
  end
end

@allowed_sports ["football", "rugby", "volleyball", "basketball", "boxing", "athletics"]

  @doc false
def changeset(game, attrs) do
  game
  |> cast(attrs, [:home_team, :away_team, :start_time, :result, :status, :bet_odds, :sport])
  |> validate_required([:home_team, :away_team, :start_time, :sport])
  |> validate_inclusion(:sport, @allowed_sports, message: "must be one of: #{Enum.join(@allowed_sports, ", ")}")
  |> validate_inclusion(:result, ["home", "away", "draw", "gg", "ng", "ov2.5", "un2.5", "1x", "2x"], message: "must be one of: home, away, draw, gg, ng, ov2.5, un2.5, 1x, 2x")
  |> validate_inclusion(:status, ["active", "started", "finished", "cancelled"], message: "must be active, started, finished, or cancelled")
  |> validate_odds_map()
end
end
