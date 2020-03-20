defmodule SignDictWeb.Backend.DomainController do
  use SignDictWeb, :controller
  alias SignDict.Domain
  alias SignDict.Entry
  alias SignDict.Video

  plug :load_and_authorize_resource, model: Domain, except: :index

  def index(conn, params) do
    domains = load_domain_list(conn, params)
    render(conn, "index.html", domains: domains)
  end

  def new(conn, _params) do
    changeset = Domain.admin_changeset(%Domain{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"domain" => domain_params}) do
    changeset = Domain.admin_changeset(%Domain{}, domain_params)

    case Repo.insert(changeset) do
      {:ok, _domain} ->
        conn
        |> put_flash(:info, gettext("Domain created successfully."))
        |> redirect(to: backend_domain_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, params) do
    domain = conn.assigns.domain

    entries_query =
      from e in Entry,
        join: domain in assoc(e, :domains),
        where: domain.id == ^domain.id,
        preload: [:language]

    entries = Repo.paginate(entries_query, params)

    render(conn, "show.html", domain: domain, entries: entries)
  end

  def edit(conn, _params) do
    domain = conn.assigns.domain
    changeset = Domain.admin_changeset(domain)
    render(conn, "edit.html", domain: domain, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "domain" => domain_params}) do
    domain = conn.assigns.domain
    changeset = Domain.admin_changeset(domain, domain_params)

    case Repo.update(changeset) do
      {:ok, domain} ->
        conn
        |> put_flash(:info, gettext("Domain updated successfully."))
        |> redirect(to: backend_domain_path(conn, :show, domain))

      {:error, changeset} ->
        render(conn, "edit.html", domain: domain, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.domain)

    conn
    |> put_flash(:info, gettext("Domain deleted successfully."))
    |> redirect(to: backend_domain_path(conn, :index))
  end

  defp load_domain_list(conn, params) do
    if Canada.Can.can?(conn.assigns.current_user, :show, %Domain{}) do
      Domain |> order_by(:id) |> Repo.paginate(params)
    else
      %Scrivener.Page{
        entries: [],
        page_number: 1,
        page_size: 25,
        total_entries: 0,
        total_pages: 1
      }
    end
  end
end
