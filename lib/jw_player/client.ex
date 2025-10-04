defmodule JwPlayer.Client do
  @jw_player Application.compile_env(:sign_dict, :jw_player)

  def sign_url(path, params \\ %{}) do
    default_map = %{
      api_nonce: Integer.to_string(Enum.random(10_000..99_999)),
      api_timestamp: Integer.to_string(DateTime.utc_now() |> DateTime.to_unix()),
      api_key: @jw_player[:api_key],
      api_format: "json"
    }

    params_with_defaults = Map.merge(default_map, params)
    "http://api.jwplatform.com/v1" <> path <> "?" <> signed_params(params_with_defaults)
  end

  defp signed_params(params) do
    params
    |> encode_values
    |> generate_query_string
    |> do_sign_url
  end

  defp do_sign_url(param_string) do
    secret = @jw_player[:api_secret]

    signature =
      :sha
      |> :crypto.hash(param_string <> secret)
      |> Base.encode16()
      |> String.downcase()

    param_string <> "&api_signature=" <> signature
  end

  defp generate_query_string(params) do
    params
    |> sorted_keys
    |> Enum.map(fn key ->
      "#{key}=#{params[key]}"
    end)
    |> Enum.join("&")
  end

  def sorted_keys(params) do
    params
    |> Map.keys()
    |> Enum.sort()
  end

  defp encode_values(params) do
    params
    |> Enum.into(%{}, fn {k, v} ->
      {URI.encode(Atom.to_string(k)), URI.encode(v)}
    end)
  end
end
