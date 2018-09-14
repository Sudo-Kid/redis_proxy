defmodule RedisProxyWeb.RedisView do
  use RedisProxyWeb, :view

  def render(_conn, %{key_value: {key, value}}) do
    %{key => value}
  end

  def render(_conn, %{error: error}) do
    %{"error"=> error}
  end

  def render(_conn, %{no_content: _}) do
    %{}
  end
end
