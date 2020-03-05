.PHONY: default
default: start ;

start:
	mix phx.server

run-test:
		mix test.watch

i18n:
		mix gettext.extract
		mix gettext.merge priv/gettext

deploy:
		mix bootleg.update prod

update:
		mix deps.get
		(cd assets && yarn install)
