defmodule TwitterWeb.RoomChannel do
    use Phoenix.Channel
    #all actions will be here
    #state: {%userid -> userid}
  
    def join("room:lobby", _message, socket) do
        engine_pid = :global.whereis_name(:engine)
        {:ok, assign(socket, :engine_pid, engine_pid)}
    end

    #TODO: if time permits, convert to 1 handle_in per action - 
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

                    String.starts_with?(body, "tweet:" )  -> #tweet
                        tweet_content = body |> String.slice(6..-1) |> String.trim()
                        if tweet_content == "" do
                            "Error: Empty tweet"
                        else
                            :ok = GenServer.call(engine_pid, {:tweet, userid, tweet_content}, :infinity)
                            "You tweeted: #{tweet_content}"
                        end    
                        
                    String.starts_with?(body, "subscribe:" ) -> #subscribe
                        subsId = body |> String.slice(10..-1) |> String.trim()
                        is_int = case :re.run(subsId, "^[0-9]*$") do
                            {:match, _} -> true
                            :nomatch -> false
                        end
                        if is_int == true do
                            subsId = subsId |> String.to_integer
                            if subsId == userid do
                                "Error: Cannot subscribe to oneself"    
                            else
                                GenServer.call(engine_pid, {:subscribe, userid, subsId}) 
                            end
                        else
                            IO.inspect "inputted non-integer id"
                            "Error: Please input a valid userid."        
                        end
                    String.starts_with?(body, "get:") -> #get # or @
                        tag = body |> String.slice(4..-1) |> String.trim()
                        cond do
                            String.starts_with?(tag, "#" ) ->
                                "Tweets with hashtag #{tag} are: " <> GenServer.call(engine_pid, {:hashtag, :hashtag, tag}) |> Enum.join(", ")
                            String.starts_with?(tag, "@" ) ->
                                "Tweets with mention #{tag} are: " <> GenServer.call(engine_pid, {:mention, :mention, tag}) |> Enum.join(", ")
                            true -> "Error: Invalid tag. It should either start with # or @"
                        end
                    String.starts_with?(body, "retweet:" ) || String.starts_with?(body, "Retweet:") -> #retweet
                        tweetid = body |> String.slice(8..-1) |> String.trim()
                        is_int = case :re.run(tweetid, "^[0-9]*$") do
                            {:match, _} -> true
                            :nomatch -> false
                        end
                        if is_int == true do
                            ret = GenServer.call(engine_pid, {:retweet, userid, tweetid |> String.to_integer}) 
                            case ret do
                                :fail -> "Error: Please input a valid tweetid to retweet."
                                {:ok, tweet} -> "You retweeted: #{tweet}"     
                            end
                        else
                            IO.inspect "inputted non-integer id"
                            "Error: Please input a valid tweetid to retweet."        
                        end

                    true -> #catch all 
                        #TODO: send all commands to screen for reference
                        "Unsupported command: " <> body
                end

        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    def handle_info({:feed, userId, tweet, tweet_id}, socket) do
        res = "UserId " <> Integer.to_string(userId) <> " tweeted: '#{tweet}'. You can use id " <> Integer.to_string(tweet_id) <> " to retweet"
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
      end

  end