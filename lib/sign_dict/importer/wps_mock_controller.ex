defmodule SignDict.Importer.WpsMockController do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Poison

  plug Plug.Static,
    at: "/videos",
    from: "test/fixtures/videos",
    only: ~w(Zug.mp4 Zug2.mp4)

  plug Plug.Static,
    at: "/images",
    from: "test/fixtures/images",
    only: ~w(russland.png)

  plug :match
  plug :dispatch

  get "/pi_json" do
    date =
      conn.params["lastRequestedDate"]
      |> Timex.parse!("%F %H:%M:%S", :strftime)
      |> NaiveDateTime.to_date()

    case date do
      ~D[2020-01-01] ->
        success(conn, [])

      ~D[2020-02-01] ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
            "dokumentId" => "123123123:12",
            "fachbegriff" => "Rechnen",
            "gebaerdenSchriftUrl" => "http://localhost:8081/images/russland.png"
          }
        ])

      ~D[2020-03-01] ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Zug2.mp4",
            "dokumentId" => "123123123:12",
            "fachbegriff" => "Zug"
          }
        ])

      ~D[2020-04-01] ->
        Plug.Conn.send_resp(conn, 200, "")

      ~D[2020-05-01] ->
        success(conn, [
          %{
            "dokumentId" => "123123123:12",
            "deleted" => "true"
          }
        ])

      _ ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
            "dokumentId" => "4347009787320352:59",
            "fachbegriff" => "Pi"
          }
        ])
    end
  end

  get "/sign_writing" do
    date =
      conn.params["lastRequestedDate"]
      |> Timex.parse!("%F %H:%M:%S", :strftime)
      |> NaiveDateTime.to_date()

    case date do
      ~D[2020-01-01] ->
        success(conn, [])

      ~D[2020-02-01] ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
            "dokumentId" => "123123123:12",
            "fachbegriff" => "Rechnen"
          }
        ])

      ~D[2020-03-01] ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
            "dokumentId" => "123123123:12",
            "fachbegriff" => "Rechnen",
            "gebaerdenSchriftUrl" => ""
          }
        ])

      ~D[2020-04-01] ->
        Plug.Conn.send_resp(conn, 200, "")

      ~D[2020-05-01] ->
        success(conn, [
          %{
            "dokumentId" => "123123123:12",
            "deleted" => "true"
          }
        ])

      ~D[2020-06-01] ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Another.mp4",
            "dokumentId" => "123123123:12",
            "fachbegriff" => "Rechnen",
            "gebaerdenSchriftUrl" => ""
          }
        ])

      _ ->
        success(conn, [
          %{
            "videoUrl" => "http://localhost:8081/videos/Zug.mp4",
            "dokumentId" => "4347009787320352:59",
            "fachbegriff" => "Pi",
            "gebaerdenSchriftUrl" => "http://localhost:8081/images/russland.png"
          }
        ])
    end
  end

  defp success(conn, body) do
    conn
    |> Plug.Conn.send_resp(200, Poison.encode!(body))
  end
end
