defmodule SignDict.Api.RegisterView do
  use SignDict.Web, :view

  alias SignDict.User

  def render(page_name, param)
  def render("create.json", %{errors: errors}) do
    %{error: errors_to_map(errors)}
  end
  def render("create.json", %{user: user}) do
    %{
      user: %{
        id: user.id,
        name: user.name,
        email: user.email || user.unconfirmed_email,
        avatar: User.avatar_url(user)
      }
    }
  end

  defp errors_to_map(errors) do
    errors
    |> Enum.map(fn {field, detail} ->
      {message, _validator} = detail
      {field, message}
    end)
    |> Enum.into(%{})
  end
end
