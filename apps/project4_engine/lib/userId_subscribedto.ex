defmodule UserIdSubscribedto do
    use GenServer
    #schema: userid string, subscribed_to_id []

    def init(state) do
        #{:write_concurrency,true}, {:read_concurrency,true}
        :ets.new(:uss_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert
    def handle_call({:insert, userId}, _from, state) do
        :ets.insert(:uss_table, {userId, []})
        {:reply, :ok, state}
    end

    #get subscribed to
    def handle_call({:get, :subscribed_to, userId}, _from, state) do
        list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1)     
        {:reply, list, state}
    end

    #update
    def handle_call({:update, userId, subscribeToId}, _from, state) do
        cond do
            :ets.lookup(:uss_table, subscribeToId) == [] -> 
                {:reply, "Error: User #{subscribeToId} does not exist",  state}
            Enum.member?(:ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1), subscribeToId) == true -> 
                {:reply, "Error: You are already subscribed to #{subscribeToId}",  state}
            true ->
                #add to subscribed_to list of userid
                subscribed_to_list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1)        
                #replace row
                :ets.insert(:uss_table, {userId, [subscribeToId | subscribed_to_list]})
                {:reply, "You are subscribed to feed of #{subscribeToId}",  state}
        end
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 

end