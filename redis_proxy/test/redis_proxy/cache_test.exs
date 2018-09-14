defmodule RedisProxy.CacheTest do
  use ExUnit.Case, async: false

  test "add and update state" do
    testState = %{size: 1, max_size: 2, order: [{"test", "hello"}], cache: %{"test"=> "hello"}}
    {newState} = RedisProxy.Cache.add({"test", "hello"}, %{size: 0, max_size: 2, order: [], cache: Map.new() }) 
    assert testState == newState

    testState = %{size: 1, max_size: 2, order: [{"test", "bye"}], cache: %{"test"=> "bye"}}
    {newState} = RedisProxy.Cache.add({"test", "bye"}, newState)
    assert testState == newState

    testState = %{size: 2, max_size: 2, order: [{"test2", "hello"}, {"test", "bye"}], cache: %{"test"=> "bye", "test2"=> "hello"}}
    {newState} = RedisProxy.Cache.add({"test2", "hello"}, newState)
    assert testState == newState

    testState = %{size: 2, max_size: 2, order: [{"test2", "hello"}, {"test", "bye"}], cache: %{"test"=> "bye", "test2"=> "hello"}}
    {newState} = RedisProxy.Cache.add({"test2", "hello"}, newState)
    assert testState == newState

    testState = %{size: 2, max_size: 2, order: [{"bye", "testing"}, {"test2", "hello"}], cache: %{"bye"=> "testing", "test2"=> "hello"}}
    {newState} = RedisProxy.Cache.add({"bye", "testing"}, newState)
    assert testState == newState
  end

  test "remove key" do
    testState = %{size: 1, max_size: 2, order: [{"test", "bye"}], cache: %{"test"=> "bye"}}
    newState = %{size: 2, max_size: 2, order: [{"test2", "hello"}, {"test", "bye"}], cache: %{"test"=> "bye", "test2"=> "hello"}}
    {newState} = RedisProxy.Cache.remove_key("test2", newState)
    assert testState == newState

    {newState} = RedisProxy.Cache.remove_key("test", newState)
    assert %{size: 0, max_size: 2, order: [], cache: %{}} == newState
  end

  test "update order" do
    testState = [{"test", "hello"}, {"test2", "bye"}]

    newState = RedisProxy.Cache.update_order("test", "hello", [{"test2", "bye"}, {"test", "hello"}])
    assert testState == newState

    testState = %{size: 2, max_size: 2, order: [{"test2", "hello!"}, {"test", "bye"}], cache: %{"test"=> "bye", "test2"=> "hello!"}}
    {newState} = RedisProxy.Cache.update({"test2", "hello!"}, %{size: 2, max_size: 2, order: [{"test", "bye"}, {"test2", "hello"}], cache: %{"test"=> "bye", "test2"=> "hello"}})
    assert testState == newState
  end

  test "get value" do
    testState = %{size: 2, max_size: 2, order: [{"test2", "hello"}, {"test", "bye"}], cache: %{"test"=> "bye", "test2"=> "hello"}}
    state = %{size: 2, max_size: 2, order: [{"test", "bye"}, {"test2", "hello"}], cache: %{"test"=> "bye", "test2"=> "hello"}}

    {value, newState} = RedisProxy.Cache.get_value("test2", state)
    assert {"hello", testState} == {value, newState}

    {value, newState} = RedisProxy.Cache.get_value("test", newState)
    assert {"bye", state} == {value, newState}

    {value, newState} = RedisProxy.Cache.get_value("test10", newState)
    assert {:nil, state} == {value, newState}
  end
end
