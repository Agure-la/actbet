defmodule Actbet.Jobs.BetChecker do
  import Ecto.Query
  alias Actbet.Repo
  alias Actbet.Bets.Bet
  alias Actbet.Games.Game
  alias Actbet.Mailer.Notifier
  require Logger

  def check_bets_and_notify do
    Logger.info("🏁 Running BetChecker at #{DateTime.utc_now()}")
    # Only check active bets
    Repo.all(from b in Bet, where: b.status == "placed", preload: [:user, :selections])
    |> Enum.each(&evaluate_bet/1)
  end

  defp evaluate_bet(bet) do
  selections_with_games =
    Enum.map(bet.selections, fn selection ->
      {selection, Repo.get(Game, selection.game_id)}
    end)

  # Check if all games have a result
  if Enum.all?(selections_with_games, fn {_sel, game} -> game && not is_nil(game.result) end) do
    # Check if all predictions match results
    all_match? =
      Enum.all?(selections_with_games, fn {selection, game} ->
        game.result == selection.choice
      end)

    if all_match? do
      # Mark as WON
      bet
      |> Ecto.Changeset.change(status: "won")
      |> Repo.update!()

      Notifier.send_winner_email(bet.user.email_address, bet)
    else
      # Mark as LOST
      bet
      |> Ecto.Changeset.change(status: "lost")
      |> Repo.update!()
    end
  else
    :noop
  end
end

end
