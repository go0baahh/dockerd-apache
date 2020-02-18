#!/usr/bin/env bash
[[ -n "${DEBUG}" ]] && set -ex || set -e

echo ${APP_ROOT}
echo ''
echo "It works!" > /var/www/html/index.html
echo -n "Checking Apache response..."
response=$(curl -s -o /dev/null -w '%{http_code}\n' dockerd.local --head)
[[ ! -z $response ]] && echo $response"...OK" || echo 'FAILED'
rm /var/www/html/index.html

echo -n "Checking Apache version..."
version=$(httpd -v | grep "Apache\/${APACHE_VER}")
[[ ! -z $version ]] && echo $version"...OK" || echo 'FAILED' ; echo $version

echo -n "Checking Apache modules..."
httpd -M > /tmp/apache_modules
if ! cmp -s /tmp/apache_modules /home/dockerd/apache_modules; then
    echo "Error: Modules are not identical:"
    diff /tmp/apache_modules /home/dockerd/apache_modules
    exit 1
    else
      echo "Identical to /apache_modules...OK"
fi
rm /tmp/apache_modules
