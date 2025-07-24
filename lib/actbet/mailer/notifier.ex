defmodule Actbet.Mailer.Notifier do
  import Swoosh.Email
  alias Actbet.Mailer

  defmodule Actbet.Mailer do
  use Swoosh.Mailer, otp_app: :actbet
end

  def send_winner_email(email, bet) do
    new()
    |> to(email)
    |> from("lameckagure@actbet.com")
    |> subject("🎉 Congratulations! You won your bet!")
    |> text_body("Congrats! Your bet (ID: #{bet.id}) has won. Check your balance.")
    |> Mailer.deliver()
  end
end
