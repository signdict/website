defmodule SignDict.Analytics.VideoAnalytic do
  use SignDictWeb, :model

  schema "video_analytics" do
    belongs_to :domain, SignDict.Domain
    belongs_to :entry, SignDict.Entry
    belongs_to :video, SignDict.Video
    belongs_to :user, SignDict.User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain_id, :entry_id, :video_id, :user_id])
    |> validate_required([:video_id])
    |> foreign_key_constraint(:video_id)
    |> foreign_key_constraint(:domain_id)
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:user_id)
  end
end
