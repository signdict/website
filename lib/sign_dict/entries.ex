defmodule SignDict.Entries do
  import Ecto.Query
  alias SignDict.Repo

  def sign_count(domain) do
    query =
      from(video in SignDict.Video,
        join: entry in assoc(video, :entry),
        join: domain in assoc(entry, :domains),
        where: video.state == "published" and domain.domain == ^domain
      )

    Repo.aggregate(query, :count, :id)
  end
end
