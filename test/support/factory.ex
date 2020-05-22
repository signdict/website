defmodule SignDict.Factory do
  use ExMachina.Ecto, repo: SignDict.Repo

  def user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hash_pwd_salt("correct_password")
    }
  end

  def user_with_avatar_factory do
    %{user_factory() | avatar: "test/fixtures/images/avatar.png"}
  end

  def admin_user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"admin-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hash_pwd_salt("correct_password"),
      role: "admin"
    }
  end

  def editor_user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"editor-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hash_pwd_salt("correct_password"),
      role: "editor"
    }
  end

  def statistic_user_factory do
    %SignDict.User{
      name: "Rebecca Smith",
      email: sequence(:email, &"editor-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hash_pwd_salt("correct_password"),
      role: "statistic"
    }
  end

  def language_dgs_factory do
    %SignDict.Language{
      iso6393: "gsg",
      long_name: "Deutsche Gebärdensprache",
      short_name: "DGS",
      default_locale: "DE"
    }
  end

  def domain_factory do
    %SignDict.Domain{domain: "signdict.org"}
  end

  def find_or_build_domain(domain) do
    SignDict.Repo.get_by(SignDict.Domain, domain: domain) || build(:domain, domain: domain)
  end

  def find_or_build_language(language) do
    SignDict.Repo.get_by(SignDict.Language, short_name: language) ||
      build(String.to_atom("language_#{String.downcase(language)}"))
  end

  def find_or_insert_language(language) do
    SignDict.Repo.get_by(SignDict.Language, short_name: language) ||
      insert(String.to_atom("language_#{String.downcase(language)}"))
  end

  def video_factory do
    %SignDict.Video{
      state: "created",
      copyright: "copyright",
      license: "license",
      original_href: "original_href",
      video_url: "http://example.com/video.mp4",
      thumbnail_url: "http://example.com/video.jpg",
      user: build(:user)
    }
  end

  def video_published_factory do
    %{video_factory() | state: "published"}
  end

  def video_with_entry_factory do
    %{video_published_factory() | entry: build(:entry)}
  end

  def entry_factory do
    %SignDict.Entry{
      description: sequence(:email, &"some content #{&1}"),
      text: "some content",
      type: "word",
      language: find_or_build_language("DGS"),
      domains: [find_or_build_domain("signdict.org")]
    }
  end

  def entry_with_videos_factory do
    %{entry_factory() | videos: build_list(4, :video_published)}
  end

  def entry_with_current_video_factory do
    entry = build(:entry_with_videos)
    %{entry | current_video: build(:video)}
  end

  def vote_factory do
    %SignDict.Vote{
      user: build(:user),
      video: build(:video)
    }
  end

  def list_factory do
    %SignDict.List{
      name: "some content",
      description: "description",
      type: "categorie-list",
      sort_order: "manual"
    }
  end

  def list_entry_factory do
    %SignDict.ListEntry{
      list: build(:list),
      entry: build(:entry_with_current_video),
      sort_order: sequence(:sort_order, fn integer -> integer end)
    }
  end
end
