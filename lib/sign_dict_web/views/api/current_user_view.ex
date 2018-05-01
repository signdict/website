defmodule SignDictWeb.Api.CurrentUserView do
  use SignDictWeb, :view

  def render(page_name, param)
  def render("show.json", %{user: nil}) do
    %{}
  end
  def render("show.json", %{user: user}) do
    SignDict.Serializer.to_map(user)
  end
end
