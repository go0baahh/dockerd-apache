#!/usr/bin/env bash
[[ -n "${DEBUG}" ]] && set -ex || set -e

action() {
    docker-compose exec "${1}" make "${@:2}" -f /usr/local/bin/actions.mk
}

is-ready() {
  docker-compose up -d
  action apache check-ready max_try=10
  docker-compose exec apache tests.sh
  docker-compose down
}

if is-ready; then
	cid="$(docker run -d -e APACHE_HTTP2=1 --name "apache-dockerd" "${IMAGE}")"
	trap "docker rm -vf $cid > /dev/null" EXIT
	docker run --rm -i -e DEBUG=1 -e apache_HTTP2=1 --link "apache-dockerd":"apache-dockerd" "${IMAGE}" make check-ready host=apache-dockerd
else
	echo "Error: Check-ready failed to respond. Could not link containers."
fi
