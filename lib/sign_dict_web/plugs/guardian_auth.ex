defmodule SignDictWeb.GuardianAuth do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :sign_dict,
                              module: SignDict.Guardian,
                              error_handler: SignDictWeb.GuardianErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true 
end
