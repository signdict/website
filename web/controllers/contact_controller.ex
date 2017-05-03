defmodule SignDict.ContactController do
  use SignDict.Web, :controller
  alias SignDict.Email
  alias SignDict.Mailer

  def new(conn, _params) do
    email = if conn.assigns.current_user do
      conn.assigns.current_user.email
    end
    render conn, "new.html", layout: {SignDict.LayoutView, "app.html"},
      email: email
  end

  def create(conn, %{"contact" => %{"email" => email, "content" => content }}) do
    mail = Email.contact_form(email, content)
    Mailer.deliver_later(mail)
    conn
    |> put_flash(:info, gettext("The email was sent."))
    |> redirect(to: "/")
  end
end
