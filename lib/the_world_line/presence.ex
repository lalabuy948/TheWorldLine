defmodule TheWorldLine.Presence do
  use Phoenix.Presence,
    otp_app: :the_world_line,
    pubsub_server: TheWorldLine.PubSub
end
