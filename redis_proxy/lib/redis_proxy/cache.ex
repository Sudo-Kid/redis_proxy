defmodule RedisProxy.Cache do
  use GenServer

  def start_link() do
    {max_size, _} = Integer.parse(System.get_env("CACHE_SIZE"))
    cache = %{size: 0, max_size: max_size, order: [], cache: Map.new()}
    GenServer.start_link(__MODULE__, {cache})
  end

  def init(state) do
    {:ok, state}
  end

  def get_value(key, state) do
    value = Map.get(state.cache, key, :nil)
    case value do
      nil ->
        {:nil, state}
      _ ->
        newOrder = update_order(key, value, state.order)
        {value, Map.put(state, :order, newOrder)}
    end
  end

  def update_order(key, value, order) do
    [{key, value}|Enum.filter(order, fn {x, _} -> x != key end)]
  end

  def add({key, value}, state) do
    case Map.has_key?(state.cache, key) do
      :true ->
        update({key, value}, state)
      :false ->
        add({state.size < state.max_size, key, value}, state)
    end
  end

  def add({:true, key, value}, state) do
    newCache = Map.put(state.cache, key, value)
    newOrder = update_order(key, value, state.order)
    newState = Map.merge(state, %{size: length(newOrder), cache: newCache, order: newOrder}) 
    {newState}
  end

  def add({:false, key, value}, state) do
    {{lru, _}, tempOrder} = List.pop_at(state.order, -1)
    {_, tempCache} = Map.pop(state.cache, lru)

    newCache = Map.put(tempCache, key, value)
    newOrder = update_order(key, value, tempOrder)
    newState = Map.merge(state, %{size: length(newOrder), cache: newCache, order: newOrder}) 
    {newState}
  end

  def update({key, value}, state) do
    newCache = Map.put(state.cache, key, value)
    newOrder = update_order(key, value, state.order)
    {Map.merge(state, %{cache: newCache, order: newOrder})}
  end

  def remove_key(key, state) do
    {_, newCache} = Map.pop(state.cache, key)
    newOrder = Enum.filter(state.order, fn {x, _} -> x != key end)
    newState = Map.merge(state, %{size: length(newOrder), cache: newCache, order: newOrder})
    {newState}
  end

  def handle_call({:get, key}, _from, {state}) do
    {value, newState} = get_value(key, state)
    {:reply, value, {newState}}
  end

  def handle_call({:clear}, _from, _state) do
    new_state = %{size: 0, max_size: 2, order: [], cache: Map.new()}
    {:reply, "cleared", {new_state}}
  end

  def handle_call(_request, _from, {state}) do
    {:reply, "bad request", {state}}
  end

  def handle_cast({:add, key, value}, {state}) do
    {:noreply, add({key, value}, state)}
  end

  def handle_cast({:remove, key}, {state}) do
    {:noreply, {remove_key(key, state)}}
  end

  def handle_cast(_request, state) do
    {:noreply, state}
  end
end

