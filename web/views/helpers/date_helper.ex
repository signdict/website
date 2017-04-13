defmodule SignDict.Helpers.DateHelper do
  import SignDict.Gettext

  def relative_date(datetime) do
    difference_in_years  = Timex.diff(Timex.now, datetime, :years)
    difference_in_months = Timex.diff(Timex.now, datetime, :months)
    difference_in_days   = Timex.diff(Timex.now, datetime, :days)

    cond do
      difference_in_years  > 0 -> ngettext("one year", "%{count} years", difference_in_years)
      difference_in_months > 0 -> ngettext("one month", "%{count} months", difference_in_months)
      difference_in_days   > 0 -> ngettext("one day", "%{count} days", difference_in_days)
      true -> "Today"
    end
  end

end
