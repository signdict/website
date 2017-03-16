defmodule SignDict.Backend.EntryController do
  use SignDict.Web, :controller
  alias SignDict.Entry
  alias SignDict.Language

  plug :load_and_authorize_resource, model: Entry

  def index(conn, _params) do
    entries = conn.assigns.entrys
              |> Repo.preload(:language)
    render(conn, "index.html", entries: entries)
  end

  def new(conn, _params) do
    changeset = Entry.changeset(%Entry{})
    languages = Repo.all(Language)
    render(conn, "new.html", changeset: changeset, languages: languages)
  end

  def create(conn, %{"entry" => entry_params}) do
    changeset = Entry.changeset(%Entry{}, entry_params)

    case Repo.insert(changeset) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, gettext("Entry created successfully."))
        |> redirect(to: backend_entry_path(conn, :index))
      {:error, changeset} ->
        languages = Repo.all(Language)
        render(conn, "new.html", changeset: changeset, languages: languages)
    end
  end

  def show(conn, _params) do
    entry = conn.assigns.entry
            |> Repo.preload(videos: :user)
            |> Repo.preload(:language)
    render(conn, "show.html", entry: entry)
  end

  def edit(conn, _params) do
    entry = conn.assigns.entry
    changeset = Entry.changeset(entry)
    languages = Repo.all(Language)
    render(conn, "edit.html", entry: entry, changeset: changeset, languages: languages)
  end

  def update(conn, %{"id" => _id, "entry" => entry_params}) do
    entry = conn.assigns.entry
    changeset = Entry.changeset(entry, entry_params)

    case Repo.update(changeset) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, gettext("Entry updated successfully."))
        |> redirect(to: backend_entry_path(conn, :show, entry))
      {:error, changeset} ->
        languages = Repo.all(Language)
        render(conn, "edit.html", entry: entry, changeset: changeset, languages: languages)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.entry)

    conn
    |> put_flash(:info, gettext("Entry deleted successfully."))
    |> redirect(to: backend_entry_path(conn, :index))
  end
end
