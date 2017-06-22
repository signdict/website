defmodule SignDict.Router do
  use SignDict.Web, :router
  use Bugsnex.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SignDict.Plug.Locale
  end

  pipeline :embed do
    plug :accepts, ["html"]
    plug :fetch_session
    plug SignDict.Plug.Locale

    plug :fetch_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug SignDict.Plug.CurrentUser
  end

  pipeline :auth do
    plug Guardian.Plug.EnsureAuthenticated,
         handler: SignDict.GuardianErrorHandler
  end

  pipeline :backend do
    plug :put_layout, {SignDict.LayoutView, :backend}
    plug SignDict.Plug.AllowedForBackend
  end

  if Application.get_env(:sign_dict, :environment) == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  scope "/", SignDict do
    pipe_through [:embed, :browser_session]

    resources "/embed", EmbedController, only: [:show] do
      get "/video/:video_id", EmbedController, :show, as: :video
    end
  end

  scope "/", SignDict do
    pipe_through [:browser, :browser_session]

    resources "/users",    UserController, except: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    resources "/recorder", RecorderController, only: [:index, :new]
    get "/recorder/new/:stuff", RecorderController, :new

    get "/email_confirmation", EmailConfirmationController, :update

    get "/password/new",  ResetPasswordController, :new
    post "/password/new", ResetPasswordController, :create
    get "/password/edit", ResetPasswordController, :edit
    put "/password",      ResetPasswordController, :update

    resources "/entry", EntryController, only: [:show] do
      get "/video/:video_id", EntryController, :show, as: :video
    end

    post "/video/:video_id/vote", VoteController, :create
    delete "/video/:video_id/vote", VoteController, :delete

    get "/search",    SearchController,  :index
    get "/imprint",   PageController,    :imprint
    get "/about",     PageController,    :about
    get "/supporter", PageController,    :supporter
    get "/privacy",   PageController,    :privacy
    get "/contact",   ContactController, :new
    post "/contact",  ContactController, :create

    get "/", PageController, :index
  end

  scope "/", SignDict do
    pipe_through [:browser, :browser_session, :auth]

    get "/welcome", PageController, :welcome
  end

  pipeline :exq do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug :browser_session
    plug :auth
    plug :backend
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  scope "/exq", ExqUi do
    pipe_through :exq
    forward "/", RouterPlug.Router, :index
  end

  # Backend functions. Only accessible to logged in admin users.
  scope "/backend", SignDict.Backend, as: :backend do
    pipe_through [:browser, :browser_session, :auth, :backend]

    get "/", DashboardController, :index

    resources "/users",  UserController
    resources "/languages", LanguageController
    resources "/entries", EntryController do
      resources "/videos", VideoController
    end
    resources "/videos", VideoController, only: [:index]
  end

  scope "/api", SignDict.Api, as: :api do
    pipe_through [:api, :browser_session]

    get "/current_user", CurrentUserController, :show
    resources "/sessions", SessionController, only: [:create]
    resources "/register", RegisterController, only: [:create]
    resources "/upload",   UploadController, only: [:create]
  end
end
