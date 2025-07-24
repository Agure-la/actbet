defmodule Actbet.Mailer.Notifier do
  import Swoosh.Email
  alias Actbet.Mailer
  require Logger

  def send_winner_email(email, bet) do
Logger.info("🏁 Sending email to  #{email}")
    new()
    |> to("email")
    |> from("estemportfolio@gmail.com")
    |> subject("🎉 Congratulations! You won your bet!")
    |> text_body("Congrats! Your bet (ID: #{bet.id}) has won. Check your balance.")
    |> Mailer.deliver()
  end
end
