defmodule SignDict.Api.CurrentUserView do
  use SignDict.Web, :view

  alias SignDict.User

  def render(page_name, param)
  def render("show.json", %{user: nil}) do
    %{}
  end
  def render("show.json", %{user: user}) do
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
