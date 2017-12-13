defmodule TwitterWeb.RoomChannel do
    use Phoenix.Channel
    #all actions will be here
    #state: {%userid -> userid}
  
    def join("room:lobby", _message, socket) do
        engine_pid = :global.whereis_name(:engine)
        {:ok, assign(socket, :engine_pid, engine_pid)}
    end

    # def join("room:" <> _private_room_id, _params, _socket) do
    #   {:error, %{reason: "unauthorized"}}
    # end

    #channel.push("new_msg", {body: chatInput.value})
    def handle_in("new_msg", %{"body" => body}, socket) do
        #TODO: add this to socket state, in join maybe
        engine_pid = socket.assigns[:engine_pid]

        res = cond do
            body == "register" -> #register
                userid = GenServer.call(engine_pid, :register)
                socket = assign(socket, :userid, userid)
                "Registered. Your userid is #{userid |> Integer.to_string}"
            String.starts_with?(body, "tweet:" ) || String.starts_with?(body, "Tweet:") -> #tweet
                tweet_content = body |> String.slice(6..139) |> String.trim()
                userid = socket.assigns[:userid]
                if userid == nil do
                    "You have not registered. First register by typing 'register' in textbox"
                else
                    :ok = GenServer.call(engine_pid, {:tweet, userid, tweet_content}, :infinity)
                    "Tweeted: #{tweet_content}"
                end
            true -> 
                "unsupported command: " <> body
        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

  end