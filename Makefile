DEV_ROCKS = busted luacheck

.PHONY: install dev lint test

install:
	luarocks make kong-custom-error-handlers-*.rockspec \

dev: install
	@for rock in $(DEV_ROCKS) ; do \
		if ! command -v $$rock > /dev/null ; then \
			echo $$rock not found, installing via luarocks... ; \
			luarocks install $$rock ; \
		else \
			echo $$rock already installed, skipping ; \
		fi \
	done;

lint:
	@luacheck -q src \
		--std 'busted' \
		--globals 'string' \
		--globals 'ngx' \
		--no-redefined \
		--no-unused-args

test:
	@busted -v spec
