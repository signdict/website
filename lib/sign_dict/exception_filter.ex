defmodule SignDict.ExceptionFilter do
  def should_notify({{%{plug_status: resp_status}, _}, _}, _stacktrace)
      when is_integer(resp_status) do
    # structure used by cowboy 2.0
    resp_status < 400 or resp_status >= 500
  end

  def should_notify(_e, _s), do: true
end
