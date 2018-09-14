defmodule RedisProxy.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(RedisProxyWeb.Endpoint, []),
      # Start your own worker by calling: RedisProxy.Worker.start_link(arg1, arg2, arg3)
      # worker(RedisProxy.Worker, [arg1, arg2, arg3]),
    ]

    :pg2.create(:cache)
    {:ok, cache} = RedisProxy.Cache.start_link()
    :pg2.join(:cache, cache)

    :pg2.create(:redis)

    {port, _} = Integer.parse(System.get_env("REDIS_PORT"))
    IO.puts "PORT #{port}"

    {:ok, redis} = Redix.start_link(host: System.get_env("REDIS_HOST"), port: port)
    :pg2.join(:redis, redis)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RedisProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RedisProxyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
