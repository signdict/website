defmodule SignDict.Helpers.DateHelperTest do
  use SignDict.ConnCase

  import SignDict.Helpers.DateHelper

  test "it returns years if difference is more than a year" do
    time = Timex.shift(Timex.now, years: -2, days: -2)
    assert relative_date(time) == "2 years"
  end

  test "it returns months if difference is more than a month" do
    time = Timex.shift(Timex.now, months: -2, days: -2)
    assert relative_date(time) == "2 months"
  end

  test "it returns days if difference is more than a day" do
    time = Timex.shift(Timex.now, days: -2)
    assert relative_date(time) == "2 days"
  end

  test "it returns today if difference is less than a day" do
    time = Timex.shift(Timex.now, hours: 1)
    assert relative_date(time) == "today"
  end
end
