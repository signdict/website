defmodule SignDict.Factory do
  use ExMachina.Ecto, repo: SignDict.Repo

  alias Comeonin.Bcrypt

  def user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hashpwsalt("correct_password")
    }
  end

  def user_with_avatar_factory do
    %{user_factory() | avatar: "test/fixtures/images/avatar.png"}
  end

  def admin_user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hashpwsalt("correct_password"),
      role: "admin"
    }
  end

  def language_dgs_factory do
    %SignDict.Language {
      iso6393: "gsg",
      long_name: "Deutsche Gebärdensprache",
      short_name: "dgs",
      default_locale: "DE"
    }
  end

  def video_factory do
    %SignDict.Video {
      state: "created",
      copyright: "copyright",
      license: "license",
      original_href: "original_href",
      video_url: "http://example.com/video.mp4",
      thumbnail_url: "http://example.com/video.jpg",
      user: build(:user)
    }
  end

  def video_with_entry_factory do
    %{video_factory() | entry: build(:entry)}
  end

  def entry_factory do
    %SignDict.Entry {
      description: "some content",
      text: "some content",
      type: "word",
      language: build(:language_dgs)
    }
  end

  def entry_with_videos_factory do
    %{entry_factory() | videos: build_list(4, :video)}
  end

  def vote_factory do
    %SignDict.Vote{
      user: build(:user),
      video: build(:video)
    }
  end
end
