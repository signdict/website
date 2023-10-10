defmodule SignDictWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :sign_dict

  socket("/socket", SignDictWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  if Application.get_env(:sign_dict, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :sign_dict,
    gzip: false,
    only: ~w(css fonts images js video_files
             favicon.ico favicon_152.png favicon_64.png
             robots.txt google4a6daf1364f4678b.html)
  )

  plug(
    Plug.Static,
    at: "/uploads",
    from: Path.expand(Application.get_env(:sign_dict, :upload_path)),
    gzip: false
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    length: 50_000_000,
    read_timeout: 60_000
  )

  plug(Plug.Accepts)
  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_sign_dict_key",
    signing_salt: "2xqY1fFX"
  )

  plug(SignDictWeb.Router)
end
