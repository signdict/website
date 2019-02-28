defmodule SignDict.Repo do
  use Ecto.Repo,
    otp_app: :sign_dict,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 25
end
