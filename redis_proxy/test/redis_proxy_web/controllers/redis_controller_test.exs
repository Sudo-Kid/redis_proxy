defmodule RedisProxyWeb.RedisControllerTest do
  use RedisProxyWeb.ConnCase, async: false
  import Mock

  def setup do
    cache_pid = :pg2.get_closest_pid(:cache) 
    GenServer.call(cache_pid, {:clear})
  end

  test "POST /", %{conn: conn} do 
    with_mock Redix,
      [
        command: fn(_, ["SET", _key, _value]) -> {:ok, "OK"} end
      ]
    do
      data = %{"cmd"=> "set", "key" => "hello", "value"=> "hello"}
      conn = post conn, "/", data
      assert json_response(conn, :created) == %{"hello"=> "hello"}
    end
  end

  test "GET / with value", %{conn: conn} do 
    with_mock Redix,
      [command: fn(_, ["GET", _key]) -> {:ok, "bye"} end]
    do
      conn = get conn, "/test"
      assert json_response(conn, :ok) == %{"test"=> "bye"}
    end
  end

  test "GET / with out value", %{conn: conn} do 
    with_mock Redix,
      [command: fn(_, ["GET", _key]) -> {:ok, nil} end,
      ]
    do
      conn = get conn, "/test"
      assert json_response(conn, :not_found) == %{"error"=> "key not found"}
    end
  end

  test "DELETE / with value",  %{conn: conn} do
    with_mock Redix,
      [command: fn(_, ["DEL", _key]) -> %{} end,
      ]
    do
      conn = delete conn, "/test"
      assert json_response(conn, :no_content) == %{}
    end
  end
end
