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

      analytic =
        Analytics.increase_video_count(
          List.first(entry.domains),
          "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53",
          nil,
          video
        )

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

      analytic =
        Analytics.increase_video_count(
          List.first(entry.domains),
          "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53",
          user,
          video
        )

      assert analytic.video_id == video.id
      assert analytic.entry_id == entry.id
      assert analytic.domain_id == List.first(entry.domains).id
      assert analytic.user_id == user.id

      entry = Repo.get!(Entry, entry.id)
      assert entry.view_count == 1

      video = Repo.get!(Video, video.id)
      assert video.view_count == 1
    end

    test "does not increase with a bot user agent" do
      user = insert(:user)

      entry =
        insert(:entry_with_videos, text: "Sloth")
        |> Entry.update_current_video()
        |> Repo.preload(:domains)

      video = entry.current_video

      analytic =
        Analytics.increase_video_count(
          List.first(entry.domains),
          "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36",
          user,
          video
        )

      assert analytic == nil

      entry = Repo.get!(Entry, entry.id)
      assert entry.view_count == 0

      video = Repo.get!(Video, video.id)
      assert video.view_count == 0
    end
  end
end
