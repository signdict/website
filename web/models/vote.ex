defmodule SignDict.Vote do
  use SignDict.Web, :model
  import SignDict.Gettext

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
    |> unique_constraint(:video_id, name: :votes_user_video_id_index,
                         message: gettext("Only one vote per video and user"))
  end

  def vote_video(user, video) do
    delete_query = from(vote in SignDict.Vote,
           inner_join: video in assoc(vote, :video),
           where: vote.user_id == ^user.id and video.entry_id == ^video.entry_id)

    delete_query
    |> SignDict.Repo.delete_all

    changeset = SignDict.Vote.changeset(%SignDict.Vote{
                                 user_id: user.id,
                                 video_id: video.id})
    SignDict.Repo.insert(changeset)
  end

end
