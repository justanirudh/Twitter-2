defmodule TwitterWeb.RoomChannel do
    use Phoenix.Channel
    #all actions will be here
  
    def join("room:lobby", _message, socket) do
      {:ok, socket}
    end

    # def join("room:" <> _private_room_id, _params, _socket) do
    #   {:error, %{reason: "unauthorized"}}
    # end

    #channel.push("new_msg", {body: chatInput.value})
    def handle_in("new_msg", %{"body" => body}, socket) do
        engine_pid = :global.whereis_name(:engine)
        res = cond do
            (body == "register") -> 
                userid = GenServer.call(engine_pid, :register) |> Integer.to_string
                "Registered. Your userid is #{userid}. You can use this for your further queries"
            true -> "unsupported command: " <> body     
        end
        broadcast! socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

  end