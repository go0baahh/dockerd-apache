.PHONY: check-ready check-live

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

host ?= dockerd.local
attempts ?= 1
wait ?= 1
delay ?= 0
command = curl -s -o /dev/null -I -w '%{http_code}' ${host}/.healthz | grep -q 204
service = Apache

default: check-ready

check-ready:
	wait-for "$(command)" $(service) $(host) $(attempts) $(wait) $(delay)

check-live:
	@echo "OK"
