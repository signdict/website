defmodule SignDict.Worker.RefreshSignWritings do
  require Bugsnex

  alias SignDict.Repo
  alias SignDict.Entry

  @process_sleep_time 100

  def perform(
        entry_id,
        sleep_ms \\ @process_sleep_time
      ) do
    IO.puts("trying things")

    Bugsnex.handle_errors %{entry_id: entry_id} do
      # Rate limit the workers, sadly i didn't find a better way :(
      Process.sleep(sleep_ms)

      IO.puts("refreshing it!")

      entry = Repo.get(Entry, entry_id) |> IO.inspect()
      SignDict.Services.FetchDelegesDataForEntry.fetch_for(entry)
    end
  end
end
