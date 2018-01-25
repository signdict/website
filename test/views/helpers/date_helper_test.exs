defmodule SignDict.Helpers.DateHelperTest do
  use SignDict.ConnCase

  import SignDict.Helpers.DateHelper

  setup do
    {:ok, date: Timex.to_datetime({{2017, 6, 24}, {4, 50, 34}}, :local)}
  end

  test "it returns years if difference is more than a year", %{date: date} do
    time = Timex.shift(date, years: -2, days: -2)
    assert relative_date(time, now: date) == "2 years"
  end

  test "it returns months if difference is more than a month", %{date: date} do
    time = Timex.shift(date, months: -2, days: -2)
    assert relative_date(time, now: date) == "2 months"
  end

  test "it returns days if difference is more than a day", %{date: date} do
    time = Timex.shift(date, days: -2)
    assert relative_date(time, now: date) == "2 days"
  end

  test "it returns today if difference is less than a day", %{date: date} do
    time = Timex.shift(date, hours: 1)
    assert relative_date(time, now: date) == "today"
  end
end
