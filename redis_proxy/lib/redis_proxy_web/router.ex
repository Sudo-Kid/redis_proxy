defmodule RedisProxyWeb.Router do
  use RedisProxyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", RedisProxyWeb do
  #  pipe_through :browser # Use the default browser stack
  # end

  # Other scopes may use custom stacks.
  scope "/", RedisProxyWeb do
    pipe_through :api

    get "/", RedisController, :index
    get "/:key", RedisController, :show
    post "/", RedisController, :create
    put "/:key", RedisController, :update
    patch "/:key", RedisController, :update
    delete "/:key", RedisController, :delete 
  end
end
