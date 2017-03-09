defmodule SignDict.Email do
  use Bamboo.Phoenix, view: SignDict.EmailView

  def password_reset(user) do
    base_email()
    |> to(user)
    |> subject("Your password reset link")
    |> assign(:user, user)
    |> render(String.to_atom("password_reset_#{Gettext.get_locale(SignDict.Gettext)}"))
  end

  defp base_email do
    new_email()
    |> from("mail@signdict.com")
    |> put_html_layout({SignDict.LayoutView, "email.html"})
  end
end

defimpl Bamboo.Formatter, for: SignDict.User do
  def format_email_address(user, _opts) do
    {user.name, user.email}
  end
end
