defmodule SignDictWeb.PageController do
  use SignDictWeb, :controller

  def index(conn, _params) do
    render(conn, get_layout_for(conn.host, "index.html"),
      layout: {SignDictWeb.LayoutView, get_layout_for(conn.host, "empty.html")},
      sign_count: SignDict.Entries.sign_count(conn.host)
    )
  end

  def imprint(conn, _params) do
    render(conn, "imprint.html", title: gettext("Imprint"))
  end

  def welcome(conn, _params) do
    render(conn, "welcome.html",
      layout: {SignDictWeb.LayoutView, "empty.html"},
      sign_count: SignDict.Entries.sign_count(conn.host),
      title: gettext("Welcome")
    )
  end

  def about(conn, _params) do
    render(conn, "about_#{Gettext.get_locale(SignDictWeb.Gettext)}.html",
      searchbar: true,
      title: gettext("About")
    )
  end

  def privacy(conn, _params) do
    render(conn, "privacy_#{Gettext.get_locale(SignDictWeb.Gettext)}.html",
      searchbar: true,
      title: gettext("Privacy")
    )
  end

  def supporter(conn, _params) do
    render(conn, "supporter.html",
      title: gettext("Supporter"),
      supporter_footer: false,
      searchbar: true
    )
  end

  def not_supported(conn, _params) do
    render(conn, "not_supported.html",
      title: gettext("Your browser is not supported"),
      supporter_footer: false,
      searchbar: true
    )
  end
end
