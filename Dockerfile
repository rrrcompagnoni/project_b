FROM elixir:1.11.3-alpine

RUN apk update

RUN mkdir /opt/project_b

WORKDIR /opt/project_b

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get
