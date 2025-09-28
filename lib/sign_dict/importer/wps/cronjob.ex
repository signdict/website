# defmodule SignDict.WpsCronjob do
#   def start_link do
#     GenServer.start_link(__MODULE__, %{})
#   end
#
#   def init(state) do
#     schedule_work()
#     {:ok, state}
#   end
#
#   def handle_info(:work, state) do
#     SignDict.Importer.Wps.SignImporter.import_json()
#     schedule_work()
#     {:noreply, state}
#   end
#
#   defp schedule_work() do
#     next_run_delay = calculate_next_cycle_delay(Timex.now())
#     Process.send_after(self(), :work, next_run_delay)
#   end
#
#   def calculate_next_cycle_delay(now) do
#     now
#     |> Timex.shift(hours: 1)
#     |> Timex.diff(now, :milliseconds)
#
#     # |> Timex.set(hour: 2, minute: 0, second: 0)
#     # |> maybe_shift_a_day(now)
#   end
#
#   #  defp maybe_shift_a_day(next_run, now) do
#   #    case Timex.before?(now, next_run) do
#   #      true ->
#   #        next_run
#   #
#   #      false ->
#   #        Timex.shift(next_run, days: 1)
#   #    end
#   #  end
# end
