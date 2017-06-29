defmodule SignDict.RecorderController do
  use SignDict.Web, :controller

  alias SignDict.Entry

  def index(conn, %{"entry_id" => entry_id}) do
    if is_nil(Repo.get(Entry, entry_id)) do
      redirect_when_no_entry(conn)
    else
      render(
        conn, "index.html", layout: {SignDict.LayoutView, "app.html"},
        entry_id: entry_id
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
        conn, "new.html", layout: {SignDict.LayoutView, "recorder.html"},
        entry_id: entry_id
      )
    end
  end
  def new(conn, _params) do
    redirect_when_no_entry(conn)
  end

  defp redirect_when_no_entry(conn) do
    conn
    |> put_flash(:error, gettext("Sorry, I couldn't find the entry for which you wanted to record a sign."))
    |> redirect(to: "/")
  end
end
