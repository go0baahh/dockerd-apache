#!/usr/bin/env bash
[[ -n "${DEBUG}" ]] && set -ex || set -e

_gote() {
    [[ -f "/etc/gote/$1" ]] && gote "/etc/gote/$1" > "$2"
}

_convert-deprecated-env-vars() {
    declare -A vars
    vars[APP_ROOT]="APACHE_DOCUMENT_ROOT"
    for i in "${!vars[@]}"; do
        [[ -n "${!i}" && -z "${!vars[$i]}" ]] && export ${vars[$i]}="${!i}"
    done
}

parse() {
	_convert-deprecated-env-vars
	_gote "httpd.conf.tmpl" "${APACHE_DIR}/conf/httpd.conf"
	_gote "vhost.conf.tmpl" "${APACHE_DIR}/conf/conf.d/vhost.conf"
	_gote "presets/${APACHE_PRESET}.conf.tmpl" "${APACHE_DIR}/conf/preset.conf"
}

sudo init_volumes
parse
exec-init

# docker exec container make <command from actions.mk>
[[ "${1}" == 'make' ]] && exec "${@}" -f /usr/local/bin/actions.mk || exec "${@}"
