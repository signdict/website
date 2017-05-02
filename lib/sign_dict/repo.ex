defmodule SignDict.Repo do
  use Ecto.Repo, otp_app: :sign_dict
  use Scrivener, page_size: 25
end
