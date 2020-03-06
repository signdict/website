defmodule SignDictWeb.Api.UploadView do
  use SignDictWeb, :view

  def render(page, params)

  def render("create.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("create.json", %{video: video}) do
    %{
      video: %{
        id: video.id,
        entry_id: video.entry_id,
        user_id: video.user_id,
        state: video.state
      }
    }
  end
end
