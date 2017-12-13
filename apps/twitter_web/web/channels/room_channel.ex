defmodule TwitterWeb.RoomChannel do
    use Phoenix.Channel
    #all actions will be here
    #state: {%userid -> userid}
  
    def join("room:lobby", _message, socket) do
        engine_pid = :global.whereis_name(:engine)
        {:ok, assign(socket, :engine_pid, engine_pid)}
    end

    #channel.push("new_msg", {body: chatInput.value})
    def handle_in("new_msg", %{"body" => body}, socket) do
        userid = socket.assigns[:userid]
        engine_pid = socket.assigns[:engine_pid]
        res = cond do
            userid == nil && body == "register" -> #register
                channel_pid = self()
                userid = GenServer.call(engine_pid, {:register, channel_pid})
                socket = assign(socket, :userid, userid)
                "Registered. Your userid is #{userid |> Integer.to_string}"
            userid == nil -> 
                "Error: You have not registered. First register by typing 'register' in textbox"
            true ->
                cond do

                    body == "register" -> #2nd time register
                        "Error: Already registered."

                    String.starts_with?(body, "tweet:" ) || String.starts_with?(body, "Tweet:") -> #tweet
                        tweet_content = body |> String.slice(6..-1) |> String.trim()        
                        :ok = GenServer.call(engine_pid, {:tweet, userid, tweet_content}, :infinity)
                        "You tweeted: #{tweet_content}"
    
                    String.starts_with?(body, "subscribe:" ) || String.starts_with?(body, "Subscribe:") ->
                        subsId = body |> String.slice(10..-1) |> String.trim()
                        is_int = case :re.run(subsId, "^[0-9]*$") do
                            {:match, _} -> true
                            :nomatch -> false
                        end
                        if is_int == true do
                            GenServer.call(engine_pid, {:subscribe, userid, subsId |> String.to_integer}) 
                        else
                            IO.inspect "inputted non-integer id"
                            "Error: Please input a valid userid."        
                        end

                    true -> #catch all 
                        #TODO: send all commands to screen for reference
                        "Unsupported command: " <> body
                end

        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    def handle_info({:feed, userId, tweet}, socket) do
        res = "UserId " <> Integer.to_string(userId) <> " tweeted: #{tweet}"
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
      end

  end