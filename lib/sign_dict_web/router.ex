defmodule SignDictWeb.Router do
  use SignDictWeb, :router
  use Plugsnag

  pipeline :locale do
    plug SignDictWeb.Plug.Locale
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SignDictWeb.Plug.SwitchLayout
  end

  pipeline :embed do
    plug :accepts, ["html"]
    plug :fetch_session
    plug SignDictWeb.Plug.Locale

    plug :fetch_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :browser_session do
    plug SignDictWeb.GuardianAuth
    plug SignDictWeb.Plug.CurrentUser
  end

  pipeline :auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :graphql do
    plug SignDictWeb.Plug.GraphqlContext
  end

  pipeline :backend do
    plug :put_layout, {SignDictWeb.LayoutView, :backend}
    plug SignDictWeb.Plug.AllowedForBackend
  end

  if Application.get_env(:sign_dict, :environment) == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", SignDictWeb do
    pipe_through [:embed, :browser_session, :locale]

    resources "/embed", EmbedController, only: [:show] do
      get "/video/:video_id", EmbedController, :show, as: :video
    end
  end

  scope "/", Sign2MintWeb, host: Application.get_env(:sign_dict, :sign2mint_domain) do
    pipe_through [:browser, :browser_session, :locale]

    get "/", PageController, :index
    get "/search", SearchController, :index

    resources "/entry", EntryController, only: [:index, :show] do
      get "/video/:video_id", EntryController, :show, as: :video
    end
  end

  scope "/", SignDictWeb do
    pipe_through [:browser, :browser_session, :locale]

    resources "/users", UserController, except: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/list", ListController, only: [:show]
    resources "/suggestion", SuggestionController, only: [:index, :create]

    get "/recorder/:entry_id", RecorderController, :index
    get "/recorder/new/:entry_id", RecorderController, :new

    get "/email_confirmation", EmailConfirmationController, :update

    get "/password/new", ResetPasswordController, :new
    post "/password/new", ResetPasswordController, :create
    get "/password/edit", ResetPasswordController, :edit
    put "/password", ResetPasswordController, :update

    resources "/entry", EntryController, only: [:index, :show, :new, :create] do
      get "/video/:video_id", EntryController, :show, as: :video
    end

    get "/latest", EntryController, :latest

    post "/video/:video_id/vote", VoteController, :create
    delete "/video/:video_id/vote", VoteController, :delete

    get "/feelinglucky", FeelingLuckyController, :index

    get "/search", SearchController, :index

    get "/about", PageController, :about
    get "/imprint", PageController, :imprint
    get "/notsupported", PageController, :not_supported
    get "/privacy", PageController, :privacy
    get "/supporter", PageController, :supporter

    get "/contact", ContactController, :new
    post "/contact", ContactController, :create

    get "/", PageController, :index
  end

  scope "/", SignDictWeb do
    pipe_through [:browser, :browser_session, :auth, :locale]

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

  # Backend functions. Only accessible to
  # logged in users with the correct role.
  scope "/backend", SignDictWeb.Backend, as: :backend do
    pipe_through [:browser, :browser_session, :auth, :backend, :locale]

    get "/", DashboardController, :index

    get "/review", ReviewController, :index
    post "/review/:video_id/approve", ReviewController, :approve_video
    put "/review/:video_id/reject", ReviewController, :reject_video

    resources "/users", UserController
    resources "/languages", LanguageController
    resources "/domains", DomainController

    resources "/entries", EntryController do
      resources "/videos", VideoController
    end

    resources "/videos", VideoController, only: [:index]

    resources "/statistic", StatisticController, only: [:index]
    resources "/csv_export_views", CSVExportViewsController, only: [:show], singleton: true

    resources "/csv_export_suggestions", CSVExportSuggestionsController,
      only: [:show],
      singleton: true

    resources "/lists", ListController do
      resources "/list_entries", ListEntryController, only: [:create, :delete]
      post "/list_entries/:id/move_up", ListEntryController, :move_up
      post "/list_entries/:id/move_down", ListEntryController, :move_down
    end
  end

  scope "/api", SignDictWeb.Api, as: :api do
    pipe_through [:api, :browser_session, :locale]

    get "/current_user", CurrentUserController, :show
    resources "/sessions", SessionController, only: [:create]
    resources "/register", RegisterController, only: [:create]
    resources "/upload", UploadController, only: [:create]
  end

  scope "/graphql-api" do
    pipe_through([:api, :graphql])

    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: SignDictWeb.Schema,
      interface: :simple
    )

    forward("/", Absinthe.Plug, schema: SignDictWeb.Schema)
  end
end
