defmodule SignDict.Services.UAInspectorDownloader do
  @moduledoc """
  Downloader adapter for `mix ua_inspector.download`.

  ua_inspector's default adapter is written against the hackney 1.x API.
  This one goes through HTTPoison, so it works with hackney 4.
  """

  @behaviour UAInspector.Downloader.Adapter

  @impl UAInspector.Downloader.Adapter
  def read_remote(location) do
    _ = Application.ensure_all_started(:httpoison)

    case HTTPoison.get(location, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status}} -> {:error, {:status, status, location}}
      {:error, _} = error -> error
    end
  end
end
