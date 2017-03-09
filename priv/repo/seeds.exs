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
