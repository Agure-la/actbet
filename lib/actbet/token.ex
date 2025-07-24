defmodule Actbet.Token do
  use Joken.Config
   @secret "jR8sGv2tY6zQp9X3uF1eKcLmNwBvHdT0RgAoEiUz"

  @signer Joken.Signer.create("HS256", @secret)

  @impl true
  def signer, do: @signer

  @impl true
  def token_config, do: default_claims()
end
