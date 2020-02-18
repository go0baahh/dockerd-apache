#!/usr/bin/env bash
[[ -n "${DEBUG}" ]] && set -ex || set -e

apache_exec() {
    docker-compose exec apache "${@}"
}

docker-compose up -d
apache_exec make check-ready max_try=10 -f /usr/local/bin/actions.mk
apache_exec sh -c 'echo "<?php echo '\''Hello World!'\'';" > /home/dockerd/code/index.php'
echo -n "Checking php endpoint"
apache_exec curl "localhost" | grep -q "Hello World!"
echo "...OK"
docker-compose down
