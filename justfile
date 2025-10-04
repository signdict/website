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

deploy:
		mix bootleg.update prod

update:
		mix deps.get
		(cd assets && yarn install)
