FROM elixir

COPY . /redis_proxy
WORKDIR /redis_proxy

RUN mix local.hex --force
RUN mix deps.get

CMD ["mix", "test"]
