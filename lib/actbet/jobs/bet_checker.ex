defmodule Actbet.Jobs.BetChecker do
  import Ecto.Query
  alias Actbet.Repo
  alias Actbet.Bets.Bet
  alias Actbet.Games.Game
  alias Actbet.Mailer.Notifier

  def check_bets_and_notify do
    # Only check active bets
    Repo.all(from b in Bet, where: b.status == "placed", preload: [:user, :selections])
    |> Enum.each(&evaluate_bet/1)
  end

  defp evaluate_bet(bet) do
    all_match? =
      Enum.all?(bet.selections, fn selection ->
        game = Repo.get(Game, selection.game_id)
        game && game.result == selection.prediction
      end)

    if all_match? do
      # Update bet status
      bet
      |> Ecto.Changeset.change(status: "won")
      |> Repo.update!()

      # Email the user
      Notifier.send_winner_email(bet.user.email_address, bet)
    else
      :noop
    end
  end
end
