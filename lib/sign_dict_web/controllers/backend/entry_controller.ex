defmodule SignDictWeb.Backend.EntryController do
  use SignDictWeb, :controller
  alias SignDict.Entry
  alias SignDict.Language

  plug :load_and_authorize_resource, model: Entry, except: :index

  def index(conn, params) do
    entries = Entry
              |> filter_entries(params["filter"])
              |> order_by(:text)
              |> preload(:language)
              |> Repo.paginate(params)

    render(conn, "index.html", entries: entries, params: params)
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
        render(conn, "edit.html", entry: entry, changeset: changeset,
               languages: languages)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.entry)

    conn
    |> put_flash(:info, gettext("Entry deleted successfully."))
    |> redirect(to: backend_entry_path(conn, :index))
  end

  defp filter_entries(query, search) do
    do_filter(query, normalize_search(search))
  end

  defp normalize_search(search) do
    if search == nil || search == "" do
      nil
    else
      search
    end
  end

  defp do_filter(query, filter) when is_nil(filter) do
    query
  end
  defp do_filter(query, filter) do
    query
    |> where([entry], ilike(entry.text, ^"#{filter}%"))
  end
end
