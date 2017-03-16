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

user = SignDict.Repo.insert!(
  %SignDict.User{
    name: "Admin User",
    email: "admin@example.com",
    password_hash: Comeonin.Bcrypt.hashpwsalt("thepasswordisalie"),
    role: "admin"
  }
)

dgs = SignDict.Repo.insert!(
  %SignDict.Language{
    iso6393: "gsg",
    long_name: "Deutsche Gebärdensprache",
    short_name: "DGS"
  }
)

hallo = SignDict.Repo.insert!(
  %SignDict.Entry{
    language: dgs,
    text: "Hallo",
    description: "",
    type: "word"
  }
)

SignDict.Repo.insert!(
  %SignDict.Video{
    state: "published",
    copyright: "dgs.wikisign.org",
    license: "CC BY-SA 3.0 DE",
    original_href: "http://dgs.wikisign.org/Hallo",
    entry: hallo,
    user: user
  }
)
