defmodule SignDict.AnalyticsTest do
  use SignDict.ConnCase
  import SignDict.Factory

  alias SignDict.Analytics
  alias SignDict.Entry
  alias SignDict.Video

  describe "increase_video_count/3" do
    test "increases the count without a user" do
      entry =
        insert(:entry_with_videos, text: "Sloth")
        |> Entry.update_current_video()
        |> Repo.preload(:domains)

      video = entry.current_video

      analytic = Analytics.increase_video_count(List.first(entry.domains), nil, video)

      assert analytic.video_id == video.id
      assert analytic.entry_id == entry.id
      assert analytic.domain_id == List.first(entry.domains).id
      assert analytic.user_id == nil

      entry = Repo.get!(Entry, entry.id)
      assert entry.view_count == 1

      video = Repo.get!(Video, video.id)
      assert video.view_count == 1
    end

    test "increases the count with a user" do
      user = insert(:user)

      entry =
        insert(:entry_with_videos, text: "Sloth")
        |> Entry.update_current_video()
        |> Repo.preload(:domains)

      video = entry.current_video

      analytic = Analytics.increase_video_count(List.first(entry.domains), user, video)

      assert analytic.video_id == video.id
      assert analytic.entry_id == entry.id
      assert analytic.domain_id == List.first(entry.domains).id
      assert analytic.user_id == user.id

      entry = Repo.get!(Entry, entry.id)
      assert entry.view_count == 1

      video = Repo.get!(Video, video.id)
      assert video.view_count == 1
    end
  end
end
