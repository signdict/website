defmodule SignDictWeb.PageController do
  use SignDictWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", layout: {SignDictWeb.LayoutView, "empty.html"},
      contributor_count: contributor_count(), sign_count: sign_count()
  end

  def imprint(conn, _params) do
    render conn, "imprint.html", layout: {SignDictWeb.LayoutView, "app.html"},
       title: gettext("Imprint")
  end

  def welcome(conn, _params) do
    render conn, "welcome.html", layout: {SignDictWeb.LayoutView, "empty.html"},
      sign_count: sign_count(), title: gettext("Welcome")
  end

  def about(conn, _params) do
    render conn, "about_#{Gettext.get_locale(SignDictWeb.Gettext)}.html", layout: {SignDictWeb.LayoutView, "app.html"},
      searchbar: true,
      title: gettext("About")
  end

  def privacy(conn, _params) do
    render conn, "privacy_#{Gettext.get_locale(SignDictWeb.Gettext)}.html", layout: {SignDictWeb.LayoutView, "app.html"},
      searchbar: true,
      title: gettext("Privacy")
  end

  def supporter(conn, _params) do
    render conn, "supporter.html", layout: {SignDictWeb.LayoutView, "app.html"},
      title: gettext("Supporter"), supporter_footer: false,
      searchbar: true
  end

  def not_supported(conn, _params) do
    render conn, "not_supported.html", layout: {SignDictWeb.LayoutView, "app.html"},
      title: gettext("Your browser is not supported"), supporter_footer: false,
      searchbar: true
  end

  defp sign_count do
    SignDict.Video
    |> where(state: "published")
    |> Repo.aggregate(:count, :id)
  end

  defp contributor_count do
    SignDict.Video
    |> where(state: "published")
    |> select([v], v.user_id)
    |> distinct(true)
    |> Repo.aggregate(:count, :user_id)
  end
end
