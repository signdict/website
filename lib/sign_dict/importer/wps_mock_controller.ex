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
            "fachbegriff" => "Rechnen"
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

  defp success(conn, body) do
    conn
    |> Plug.Conn.send_resp(200, Poison.encode!(body))
  end
end
