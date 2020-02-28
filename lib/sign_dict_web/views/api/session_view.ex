defmodule SignDictWeb.Api.SessionView do
  use SignDictWeb, :view

  def render(page_name, param)

  def render("create.json", %{error: error}) do
    %{error: error}
  end

  def render("create.json", %{user: user}) do
    SignDict.Serializer.to_map(user)
  end
end
