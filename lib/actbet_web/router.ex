defmodule ActbetWeb.Router do
  use ActbetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ActbetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
  plug ActbetWeb.Plugs.Auth
  end

  # no auth
  scope "/api", ActbetWeb do
    pipe_through :api

    get "/", PageController, :home
    post "/register", AuthController, :register
     post "/login", AuthController, :login

  end

  scope "/api", ActbetWeb do
  pipe_through [:api, :auth]

  #bets
  post "/bets", BetController, :create
  get "/bets", BetController, :user_bets

  #games
   post "/games", GameController, :create
  get "/games", GameController, :index
  get "/games/:id", GameController, :show
  patch "/games/:id/finish", GameController, :finish
end

  # Other scopes may use custom stacks.
  # scope "/api", ActbetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:actbet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ActbetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
