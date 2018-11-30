defmodule Advent.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug Plug.Logger

  plug Clova.SkillPlug,
    dispatch_to: Advent,
    app_id: "com.example.advent",
    json_module: Poison,
    force_signature_valid: Application.get_env(:advent, :force_signature_valid, false)

  plug :match
  plug :dispatch

  post "/clova" do
    send_resp(conn)
  end

  match("/clova", do: send_resp(conn, :method_not_allowed, ""))
  match(_, do: send_resp(conn, :not_found, ""))

  def handle_errors(conn, %{kind: :error, reason: reason}) do
    send_resp(conn, conn.status, Exception.message(reason))
  end
end
