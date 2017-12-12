defmodule Engine do
    use GenServer
    @feed_lim 20
    #state:%{:curr_user_id => curr_user_id, :curr_tweet_id => curr_tweet_id, :client_master_pid => client_master_pid,
    # :print_every => print_every}

    defp get_hashtags(tweet) do
        (String.split tweet) |> Enum.filter(fn(str) -> String.starts_with? str, "#" end)
    end

    defp get_mentions(tweet) do
        (String.split tweet) |> Enum.filter(fn(str) -> String.starts_with? str, "@" end)
    end

    defp get_latest_tweets(tweetIds) do
        #list of (tweets,timestamps)
        #arrange in decreasing order of timestamps
        #get first @feed_lim tweets
        Enum.map(tweetIds, fn(tweetId) -> GenServer.call(:tt, {:get, tweetId}) end) 
        |> (Enum.sort_by &(elem(&1, 1)), &>=/2) 
        |> Enum.take(@feed_lim)
        |> Enum.map(fn({tw,_}) -> tw end)
    end

    def init(state) do
        #epmd -daemon
        {:ok, _} = Node.start(String.to_atom("engine@127.0.0.1"))
        Application.get_env(:p4, :cookie) |> Node.set_cookie
        {:ok, state}
    end

    #register client_master
    def handle_call({:register_client_master, client_master_pid, print_every}, _from, state) do
        IO.inspect "client-master registered"
        state = Map.put(state, :client_master_pid, client_master_pid)
        {:reply, :ok, Map.put(state, :print_every, print_every)}
    end

    #register - tested
    def handle_call(:register, _from, state) do
        curr_user_id = Map.get(state, :curr_user_id)
        #IO.inspect "registering user with id #{curr_user_id}"
        :ok = GenServer.call(:uss, {:insert, curr_user_id})
        {:reply, curr_user_id, Map.put(state, :curr_user_id, curr_user_id + 1 )} #reply their userid to client
    end

    #feed-tested
    def handle_call({:feed, userId}, _from, state) do
        #list of userids
        subscribed_to_list = GenServer.call(:uss, {:get, :subscribed_to, userId})
        #list of tweetids
        tweetIds = Enum.flat_map(subscribed_to_list, fn(userId) -> GenServer.call(:ut, {:get, userId}) end)
        #list of tweets
        tweets = get_latest_tweets(tweetIds)    
        {:reply, tweets, state} 
    end

    #hashtags-tested
    def handle_call({:hashtag, :hashtag, hashtag}, _from, state) do
        tweetIds = GenServer.call(:ht, {:get, :hashtag, hashtag})
        #list of tweets
        tweets = get_latest_tweets(tweetIds) 
        {:reply, tweets, state}    
    end

    #hashtag-getkeys
    def handle_call({:hashtag, :getkeys}, _from, state) do
        list = GenServer.call(:ht, {:get, :keys})
        {:reply, list, state}    
    end

    #mentions-tested
    def handle_call({:mention, :mention,mention}, _from, state) do
        tweetIds = GenServer.call(:mt, {:get, :mention, mention})
        #list of tweets
        tweets = get_latest_tweets(tweetIds) 
        {:reply, tweets, state}    
    end

    #mention-getkeys
    def handle_call({:mention, :getkeys}, _from, state) do
        list = GenServer.call(:mt, {:get, :keys})
        {:reply, list, state}    
    end

    #subscribe - tested
    def handle_call({:subscribe, userId, subscribeToId}, _from, state) do
        IO.inspect "subscribing #{userId} to #{subscribeToId}"
        res = GenServer.call(:uss, {:update, userId, subscribeToId})
        {:reply, res, state} 
    end

    #tweet-tested
    def handle_call({:tweet, userId, tweet}, _from,state) do
        curr_time = System.monotonic_time(:microsecond)
        hashtags = get_hashtags(tweet)
        mentions = get_mentions(tweet)
        curr_tweet_id = Map.get(state, :curr_tweet_id)
        #Not required for this project. Was only for simulation for calculating stats
        #print_every = Map.get(state, :print_every)
        # if curr_tweet_id != 0 && rem(curr_tweet_id, print_every) == 0 do
        #     IO.inspect state
        #     client_master_pid = Map.get(state, :client_master_pid)
        #     send client_master_pid, {:print, print_every} 
        #     IO.inspect "sent stats to client-master"   
        # end
        #add to userid-tweetids table
        :ok = GenServer.call(:ut, {:insert_or_update, userId, curr_tweet_id}, :infinity)
        #add to tweetid-tweet-ts table
        :ok = GenServer.call(:tt, {:insert, curr_tweet_id, tweet, curr_time}, :infinity)
        #add to hashtag-tweetid table
        if(hashtags != []) do
            :ok = GenServer.call(:ht, {:insert_or_update, hashtags, curr_tweet_id}, :infinity)    
        end     
        #add to mention-tweedtid table
        if(mentions != []) do
            :ok = GenServer.call(:mt, {:insert_or_update, mentions, curr_tweet_id}, :infinity)    
        end

        {:reply, :ok, Map.put(state, :curr_tweet_id, curr_tweet_id + 1)} 
    end
end