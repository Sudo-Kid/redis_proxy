defmodule RedisProxyWeb.RedisController do
  use RedisProxyWeb, :controller

  def command(["SET", key, value]) do
    redis_pid = :pg2.get_closest_pid(:redis)
    Redix.command(redis_pid, ["SET", key, value])
  end

  def command(["GET", key]) do
    cache_pid = :pg2.get_closest_pid(:cache) 
    response = GenServer.call(cache_pid, {:get, key})
    case response do
      nil ->
        redis_pid = :pg2.get_closest_pid(:redis)
        Redix.command(redis_pid, ["GET", key])
      value ->
        {:ok, value}
    end
  end

  def command(["DELETE", key]) do
    cache_pid = :pg2.get_closest_pid(:cache) 
    GenServer.cast(cache_pid, {:remove, key})

    redis_pid = :pg2.get_closest_pid(:redis)
    Redix.command(redis_pid, ["GET", key])
  end

  def command(_) do
    {:ok, :nil}
  end

  def index(conn, _params) do
    render(conn, "show.json", %{no_content: "no_content"})
  end

  def show(conn, %{"key"=> key}) do
    case command([String.upcase("GET"), key]) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> render("show.json", %{error: "key not found"})
      {:ok, value} ->
        render(conn, "show.json", %{key_value: {key, value}})
      {:error, %Redix.ConnectionError{reason: :closed}} ->
        conn
        |> put_status(500)
        |> render("show.json", %{error: "Not in cache and redis is offline"})
    end
  end

  def create(conn, %{"key"=> key, "value"=> value}) do
    case command([String.upcase("SET"), key, value]) do
      {:ok, "OK"} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{key_value: {key, value}})
      {:error, %Redix.ConnectionError{reason: :closed}} ->
        conn
        |> put_status(500)
        |> render("show.json", %{error: "Not in cache and redis is offline"})
    end
  end

  def create(conn, %{"cmd"=> cmd, "key"=> key, "value"=> value}) do
    {:ok, "OK"} = command([String.upcase(cmd), key, value])
    conn
    |> put_status(:created)
    |> render("show.json", %{key_value: {key, value}})
  end

  def update(conn, _params) do
    render(conn, "show.json", %{"data"=> "hello"})
  end

  def delete(conn, %{"key"=> key}) do
    {:ok, _} = command(["DEL", key])
    conn
    |> put_status(:no_content)
    |> render("show.json", %{no_content: key})
  end
end
