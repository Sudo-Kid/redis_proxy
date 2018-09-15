# RedisProxy
## High-level architecture overview:
### Language:
- Elixir

### Libraries:
- Phoenix
- Redix
- Mock

### Reasons for picking language/libraries:
I picked Elixir for the parallel concurrent processing aspects of the beam, Phoenix as its the framework I know best in Elixir, Redix to connect to the Redis to speed up the implementation, Mock to reproduce Redis results well testing without a Redis server.

## What the code does:
The system attached will provide an individual green thread beam process for each HTTP connection. This allows the application full access to the hardware well isolating the HTTP connections. When the connection comes it evaluates the command provided and dispatches an asynchronous or synchronous request to the LRU cache and then falls back to the Redis connection if needed. I have picked asynchronous dispatching for all calls that do not return data such as SET/DEL andsynchronous dispatching for GET.

## Algorithmic complexity of the cache operations:
The complexity of all cache operations: O(n)

With this system being built in a functional programming language there are some limitations that make the LRU Cache an O(n) complexity issue. Well, I did create a C++ LRU cache and made an effort to turn it into a NIF library for Erlangit was unsuccessful. I ran into compilation issues when attempting to hold a globally scoped object in the C++ NIF file. This LRU cache would have allowed for constant time access and updating to prevent the large overhead incurred by updating the Elixir cache. I believe that given more time I could migrate the C++ code to a C Node library to gain such functionality though more research would need to be done to verify this.

## Instructions on how to run the proxy and tests:
### Testing:
You can run the tests with `mix test`. This will deploy 2 docker containers using `docker-compose` and run the unit tests. The configurations are all set in the `docker-compose.yml` file. If you would like to run the tests on your local host system outside of docker you the command `mix test` can be used.

### Deploy:
I have provided a list of all environment variables below.

- REDIS_HOST - Host IP/Domain for the Redis server
- REDIS_PORT - Port that Reids is running on
- CACHE_SIZE - Max size of the LRU cache
- PARALLEL_CACHE - The number of parallel caches to use on a single instance
- PORT - The port to run the web server on
- MIX_ENV - This can be set to “prod” for a production server - Not tested but should work

The system can be run as a server by setting the environment variables “REDIS_HOST, REDIS_PORT, CACHE_SIZE” and then running `mix phx.server`. If you would like to change the port that Phoenix runs on you can set the environment variable“PORT” before running.

## How long I spent on each part:
- 1 Hour: Phoenix API’s
- 1 Hour: Elixir LRU cache
- 3 Hours: Failed C++ LRU NIF
- 1 Hour: Documentation
- 30 Mins: Automated testing with make

## Failed to implement requirements:
- Redis client protocol
- Cache expiry time
- Redis calls implemented “GET, SET, DEL”

I was unable to implement some of the requirements due to a lack of time. Well, testing in the early stages I was able to get the first bit of my C++ NIF LRU Cache working and as such continued to work on it. Though after completion whenattempting to finish the NIF integration code to Erlang there where unexpected compilation errors. This meant that I needed to rush a rebuild of the code in Elixir and I was unable to complete all the functionality requested.
