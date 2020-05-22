defmodule SignDict.Analytics do
  import Ecto.Query, warn: false

  alias SignDict.Analytics.VideoAnalytic
  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video

  def increase_video_count(domain, user_agent, user, video) do
    Repo.get!(Video, video.id)

    if UAInspector.bot?(user_agent) do
      nil
    else
      do_increase_video_count(domain, user, video)
    end
  end

  defp do_increase_video_count(domain, user, video) do
    from(
      e in Entry,
      where: e.id == ^video.entry_id,
      update: [inc: [view_count: 1]]
    )
    |> Repo.update_all([])

    from(
      v in Video,
      where: v.id == ^video.id,
      update: [inc: [view_count: 1]]
    )
    |> Repo.update_all([])

    VideoAnalytic.changeset(%VideoAnalytic{}, %{
      domain_id: domain.id,
      user_id: user && user.id,
      video_id: video.id,
      entry_id: video.entry_id
    })
    |> Repo.insert!()
  end
end
