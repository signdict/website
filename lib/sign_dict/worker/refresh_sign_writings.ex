defmodule SignDict.Worker.RefreshSignWritings do
  require Bugsnex

  alias SignDict.Repo
  alias SignDict.Entry

  @process_sleep_time 100

  def perform(
        entry_id,
        fetch_service \\ SignDict.Services.FetchDelegesDataForEntry,
        sleep_ms \\ @process_sleep_time
      ) do
    Bugsnex.handle_errors %{entry_id: entry_id} do
      # Rate limit the workers, sadly i didn't find a better way :(
      Process.sleep(sleep_ms)

      entry = Repo.get(Entry, entry_id)
      fetch_service.fetch_for(entry)
    end
  end
end
