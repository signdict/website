defmodule SignDict.Vote do
  use SignDictWeb, :model
  import SignDictWeb.Gettext

  alias SignDict.Repo
  alias SignDict.Vote
  alias SignDict.Entry

  schema "votes" do
    belongs_to :user, SignDict.User
    belongs_to :video, SignDict.Video

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :video_id])
    |> validate_required([:user_id, :video_id])
    |> unique_constraint(:video_id,
      name: :votes_user_video_id_index,
      message: gettext("Only one vote per video and user")
    )
  end

  def vote_video(user, video) do
    delete_query =
      from(vote in Vote,
        inner_join: video in assoc(vote, :video),
        where: vote.user_id == ^user.id and video.entry_id == ^video.entry_id
      )

    delete_query
    |> Repo.delete_all()

    changeset = Vote.changeset(%Vote{user_id: user.id, video_id: video.id})
    result = Repo.insert(changeset)

    Entry.update_current_video(video.entry)

    result
  end

  def delete_vote(user, video) do
    delete_query =
      from(vote in Vote,
        where: vote.user_id == ^user.id and vote.video_id == ^video.id
      )

    delete_query |> Repo.delete_all()
    Entry.update_current_video(video.entry)
  end
end
