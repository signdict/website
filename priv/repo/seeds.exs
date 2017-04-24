# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SignDict.Repo.insert!(%SignDict.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

SignDict.Repo.insert!(
  %SignDict.User{
    name: "Admin User",
    email: "admin@example.com",
    password_hash: Comeonin.Bcrypt.hashpwsalt("thepasswordisalie"),
    role: "admin"
  }
)

user = SignDict.Repo.insert!(
  %SignDict.User{
    name: "User",
    email: "homer@example.com",
    password_hash: Comeonin.Bcrypt.hashpwsalt("donut")
  }
)

dgs = SignDict.Repo.insert!(
  %SignDict.Language{
    iso6393: "gsg",
    long_name: "Deutsche Gebärdensprache",
    short_name: "DGS",
    default_locale: "de"
  }
)

aufnehmen = SignDict.Repo.insert!(
  %SignDict.Entry{
    language: dgs,
    text: "Zug",
    description: "",
    type: "word"
  }
)

File.mkdir("priv/static/video_files")
File.cp("test/fixtures/videos/Zug.mp4", "priv/static/video_files/Zug.mp4")
File.cp("test/fixtures/videos/Zug.jpg", "priv/static/video_files/Zug.jpg")
File.cp("test/fixtures/videos/Zug2.mp4", "priv/static/video_files/Zug2.mp4")
File.cp("test/fixtures/videos/Zug2.jpg", "priv/static/video_files/Zug2.jpg")

SignDict.Repo.insert!(
  %SignDict.Video{
    state: "published",
    copyright: "Henrike Maria Falke - gebaerdenlernen.de",
    license: "by-nc-sa/3.0/de",
    original_href: "http://www.gebaerdenlernen.de/index.php?article_id=176",
    thumbnail_url: "/video_files/Zug.jpg",
    video_url: "/video_files/Zug.mp4",
    entry: aufnehmen,
    user: user
  }
)

zug2 = SignDict.Repo.insert!(
  %SignDict.Video{
    state: "published",
    copyright: "Philipps - dgs.wikisign.org",
    license: "by-sa/3.0/de",
    original_href: "http://dgs.wikisign.org/Zug2",
    thumbnail_url: "/video_files/Zug2.jpg",
    video_url: "/video_files/Zug2.mp4",
    entry: aufnehmen,
    user: user
  }
)

SignDict.Repo.insert!(
  %SignDict.Vote{
    video: zug2,
    user: user
  }
)

