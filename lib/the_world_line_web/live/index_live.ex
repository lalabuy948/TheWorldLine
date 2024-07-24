defmodule TheWorldLineWeb.IndexLive do
  use TheWorldLineWeb, :live_view

  alias TheWorldLine.NicknameStorage
  alias TheWorldLine.MessageStorage
  alias TheWorldLine.Presence

  @presence_topic "presence"

  def mount(_params, _session, socket) do
    if connected?(socket), do: MessageStorage.subscribe()
    if connected?(socket), do: Phoenix.PubSub.subscribe(TheWorldLine.PubSub, @presence_topic)

    messages = MessageStorage.get_messages()
    initial_presence = Presence.list(@presence_topic) |> map_size

    assigns = [
      present: initial_presence,
      messages: messages,
      logged_in: false,
      nickname: nil,
      error: nil
    ]

    {:ok, assign(socket, assigns)}
  end

  # --- UI events ---

  def handle_event("validate", %{"nickname" => nickname}, socket) do
    case validate_nickname(nickname) do
      :ok -> {:noreply, assign(socket, nickname: nickname, error: nil)}
      {:error, message} -> {:noreply, assign(socket, error: message)}
    end
  end

  def handle_event("login", %{"nickname" => nickname}, socket) do
    NicknameStorage.add(nickname)
    Presence.track(self(), @presence_topic, nickname, %{})
    {:noreply, assign(socket, nickname: nickname, logged_in: true)}
  end

  def handle_event("new_message", %{"text" => message}, socket) do
    if message != "",
      do: MessageStorage.add_message(%{message: message, nickname: socket.assigns.nickname})

    {:noreply, socket}
  end

  defp validate_nickname(nickname) do
    cond do
      String.length(nickname) < 3 ->
        {:error, "Must be at least 3 characters long"}

      String.length(nickname) > 20 ->
        {:error, "Must be maximum 20 characters long"}

      NicknameStorage.exists?(nickname) ->
        {:error, "Nickname already taken"}

      true ->
        :ok
    end
  end

  # --- messages funcitonality ---

  def handle_info({:messages_were_deleted, messages}, socket) do
    {:noreply, assign(socket, messages: messages)}
  end

  def handle_info({:message_created, message}, socket) do
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end

  # -- presence functionality ---

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: present}} = socket
      ) do
    new_present = present + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :present, new_present)}
  end

  # -- handle logout ---

  def terminate(_reason, socket) do
    NicknameStorage.delete(socket.assigns.nickname)

    :ok
  end
end
