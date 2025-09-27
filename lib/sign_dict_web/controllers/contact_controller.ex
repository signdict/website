defmodule SignDictWeb.ContactController do
  use SignDictWeb, :controller
  alias SignDictWeb.Email
  alias SignDictWeb.Mailer

  def new(conn, _params) do
    email = user_email(conn.assigns)

    render(conn, "new.html",
      email: email,
      content: ""
    )
  end

  def create(conn = %{assigns: %{current_user: current_user}}, params)
      when not is_nil(current_user) do
    %{"contact" => %{"email" => email, "content" => content}} = params
    send_email(conn, email, content)
  end

  def create(conn, params) do
    %{"contact" => %{"email" => email, "content" => content}} = params

    send_email(conn, email, content)
  end

  defp send_email(conn, email, content) do
    mail = Email.contact_form(email, content)
    Mailer.deliver_later(mail)

    conn
    |> put_flash(:info, gettext("The email was sent."))
    |> redirect(to: "/")
  end

  defp show_error(conn, email, content) do
    conn
    |> put_flash(:error, gettext("The recaptcha was wrong, email not sent."))
    |> render("new.html",
      email: email,
      content: content
    )
  end

  defp user_email(%{assigns: %{current_user: %{email: email}}}) when not is_nil(email) do
    email
  end

  defp user_email(_param) do
    nil
  end
end
