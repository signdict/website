defmodule SignDict.Backend.ReviewController do
  use SignDict.Web, :controller
  alias SignDict.Video

  def index(conn, params) do
    videos = Video
             |> where([c], c.state == "waiting_for_review")
             |> order_by(:updated_at)
             |> preload(:entry)
             |> Repo.paginate(params)
    render(conn, "index.html", videos: videos)
  end

end
