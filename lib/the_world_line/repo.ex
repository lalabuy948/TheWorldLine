defmodule TheWorldLine.Repo do
  use Ecto.Repo,
    otp_app: :the_world_line,
    adapter: Ecto.Adapters.SQLite3
end
