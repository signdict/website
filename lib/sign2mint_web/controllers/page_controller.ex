defmodule Sign2MintWeb.PageController do
  use Sign2MintWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      layout: {Sign2MintWeb.LayoutView, "empty.html"},
      sign_count: SignDict.Entries.sign_count(conn.host)
    )
  end

  def imprint(conn, _params) do
    render(conn, "imprint.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end
end
