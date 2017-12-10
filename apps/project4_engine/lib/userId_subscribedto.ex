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
        if(:ets.lookup(:uss_table, userId) == [] || 
        :ets.lookup(:uss_table, subscribeToId) == [] ||
        Enum.member?(:ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1), subscribeToId) == true) do
            #if either of them is not registered OR if they are already in each other's lists
            IO.inspect "either ids not registered or already subscribed"
            #NOP
        else
            #add to subscribed_to list of userid
            subscribed_to_list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1)        
            #replace row
            :ets.insert(:uss_table, {userId, [subscribeToId | subscribed_to_list]})
        end
        {:reply, :ok,  state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 

end