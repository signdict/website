defmodule Sign2MintWeb.PageController do
  use Sign2MintWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      layout: {Sign2MintWeb.LayoutView, "empty.html"},
      sign_count: SignDict.Entries.sign_count(conn.host)
    )
  end
end
