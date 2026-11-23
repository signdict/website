default: start

start:
	mix phx.server

test:
		mix test.interactive --clear

check:
		mix check

i18n:
		mix gettext.extract
		mix gettext.merge priv/gettext

format:
		mix format
		(cd assets && yarn format)

# Update translations and format all Elixir and JS code
tidy: i18n format

update:
		mix deps.get
		(cd assets && yarn install --frozen-lockfile)
