defmodule SignDictWeb.RecorderController do
  use SignDictWeb, :controller

  alias SignDict.Entry

  def index(conn, %{"entry_id" => entry_id}) do
    entry = Repo.get(Entry, entry_id)

    if is_nil(entry) do
      redirect_when_no_entry(conn)
    else
      render(
        conn,
        "index_#{Gettext.get_locale(SignDictWeb.Gettext)}.html",
        layout: {SignDictWeb.LayoutView, "app.html"},
        entry: entry
      )
    end
  end

  def index(conn, _params) do
    redirect_when_no_entry(conn)
  end

  def new(conn, %{"entry_id" => entry_id}) do
    if is_nil(Repo.get(Entry, entry_id)) do
      redirect_when_no_entry(conn)
    else
      render(
        conn,
        "new.html",
        layout: {SignDictWeb.LayoutView, "recorder.html"},
        entry_id: entry_id
      )
    end
  end

  def new(conn, _params) do
    redirect_when_no_entry(conn)
  end

  defp redirect_when_no_entry(conn) do
    conn
    |> put_flash(
      :error,
      gettext("Sorry, I couldn't find the entry for which you wanted to record a sign.")
    )
    |> redirect(to: "/")
  end
end
