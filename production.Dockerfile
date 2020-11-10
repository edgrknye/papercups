FROM elixir:1.10.4 as prod

# build step
ARG APP_VER=0.0.1
ENV MIX_ENV=prod
ENV NODE_ENV=production
ENV APP_VERSION=$APP_VER

RUN mkdir /app
WORKDIR /app

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs fswatch


# Client side
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix=assets

# fix because of https://github.com/facebook/create-react-app/issues/8413
ENV GENERATE_SOURCEMAP=false

COPY priv priv
COPY assets assets
RUN npm run build --prefix=assets

COPY mix.exs mix.lock ./
COPY config config

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

COPY lib lib
RUN mix deps.compile
RUN mix phx.digest

WORKDIR /app
RUN mix release 
ENV LANG=C.UTF-8

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

RUN adduser -home /app -u 1000 --shell /bin/sh --disabled-password  --gecos "" papercupsuser
RUN chown -R papercupsuser:papercupsuser /app

USER papercupsuser
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]

# # Main Docker Image
# FROM alpine:3.11
# ENV LANG=C.UTF-8

# RUN apk add --no-cache openssl ncurses

# COPY docker-entrypoint.sh /entrypoint.sh

# RUN chown -R papercupsuser:papercupsuser /app
# USER papercups
# WORKDIR /app
# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["run"]

# ARG MIX_ENV=prod
# FROM elixir:1.10 as prod
# ENV MIX_HOME=/opt/mix

# WORKDIR /usr/src/app
# ENV LANG=C.UTF-8

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
#     apt-get install -y nodejs fswatch && \
#     mix local.hex --force && \
#     mix local.rebar --force

# # declared here since they are required at build and run time.
# ENV DATABASE_URL="ecto://postgres:postgres@localhost/chat_api" SECRET_KEY_BASE="" FROM_ADDRESS="" MAILGUN_API_KEY=""

# COPY mix.exs mix.lock ./
# COPY config config
# RUN mix do deps.get, deps.compile

# COPY assets/package.json assets/package-lock.json ./assets/
# RUN npm install --prefix=assets

# # Temporary fix because of https://github.com/facebook/create-react-app/issues/8413
# ENV GENERATE_SOURCEMAP=false

# COPY priv priv
# COPY assets assets
# RUN npm run build --prefix=assets

# COPY lib lib
# RUN mix do compile
# RUN mix phx.digest

# COPY docker-entrypoint.sh .
# # CMD ["/usr/src/app/docker-entrypoint.sh"]
# RUN POOL_SIZE=2 mix ecto.setup
# RUN mix deps.compile certifi
# RUN echo "Run: mix phx.swagger.generate to generate swagger docs" 
# RUN MIX_ENV=prod mix phx.server