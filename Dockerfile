# Builder: the official Elixir image (https://hub.docker.com/_/elixir). Its
# `<elixir>-otp-<major>-slim` tags are rebuilt for every OTP patch release and
# are based on Debian (currently trixie).
# Runner: plain Debian (https://hub.docker.com/_/debian). Keep it on the same
# Debian release as the builder so the compiled NIFs (bcrypt, quic) match the
# runner's glibc/OpenSSL.
#
ARG ELIXIR_VERSION=1.20.5
ARG OTP_MAJOR=29
ARG RUNNER_DEBIAN_VERSION=trixie-20261104-slim

ARG BUILDER_IMAGE="elixir:${ELIXIR_VERSION}-otp-${OTP_MAJOR}-slim"
ARG RUNNER_IMAGE="debian:${RUNNER_DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl libssl-dev \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/

RUN mix deps.get --only $MIX_ENV

# Install nvm + Node.js + Yarn
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=26.13.1

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_VERSION \
  && nvm use $NODE_VERSION \
  && ln -s "$NVM_DIR/versions/node/$(nvm version $NODE_VERSION)" "$NVM_DIR/current" \
  && npm install -g yarn@1.22.22

# Make node and yarn available in PATH
ENV PATH=$NVM_DIR/current/bin:$PATH

RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
# RUN mix assets.deploy
RUN cd assets && yarn install --frozen-lockfile && yarn deploy

# Compile the release
RUN mix compile

# Add digest things
RUN mix phx.digest

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# Download UA Inspector files
RUN mix ua_inspector.download --force

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y libstdc++6 openssl libncurses6 libsctp1 locales ca-certificates curl imagemagick wget \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/sign_dict ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]
#
CMD ["sh", "/app/bin/entrypoint"]
