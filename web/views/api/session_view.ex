defmodule SignDict.Api.SessionView do
  use SignDict.Web, :view

  alias SignDict.User

  def render(page_name, param)
  def render("create.json", %{error: error}) do
    %{error: error}
  end
  def render("create.json", %{user: user}) do
    %{
      user: %{
        id: user.id,
        name: user.name,
        email: user.email,
        avatar: User.avatar_url(user)
      }
    }
  end
end
