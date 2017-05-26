defmodule SignDict.RecorderController do
  use SignDict.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", layout: {SignDict.LayoutView, "app.html"}
  end

  def new(conn, _params) do
    render conn, "new.html", layout: {SignDict.LayoutView, "recorder.html"}
  end
end
