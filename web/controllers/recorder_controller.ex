defmodule SignDict.RecorderController do
  use SignDict.Web, :controller

  def index(conn, params) do
    render conn, "index.html", layout: {SignDict.LayoutView, "app.html"},
      entry_id: params["entry_id"]
  end

  def new(conn, params) do
    render conn, "new.html", layout: {SignDict.LayoutView, "recorder.html"},
      entry_id: params["entry_id"]
  end
end
