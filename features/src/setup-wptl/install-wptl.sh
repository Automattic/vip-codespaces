#!/bin/sh

set -e

download_wp() {
	VERSION="$1"
	if [ "${VERSION}" = "nightly" ] || [ "${VERSION}" = "trunk" ]; then
		TESTS_TAG="trunk"
	elif [ "${VERSION}" = "latest" ]; then
		VERSIONS=$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - )
		LATEST=$(echo "${VERSIONS}" | jq -r '.offers | map(select( .response == "upgrade")) | .[0].version')
		if [ -z "${LATEST}" ]; then
			echo "Unable to detect the latest WP version"
			exit 1
		fi

		download_wp "${LATEST}"
		ln -sf "/usr/share/wptl/wordpress-${LATEST}" /usr/share/wptl/wordpress-latest
		ln -sf "/usr/share/wptl/wordpress-tests-lib-${LATEST}" /usr/share/wptl/wordpress-tests-lib-latest
		return
	elif [ "${VERSION%.x}" != "${VERSION}" ]; then
		VER="${VERSION}"
		LATEST=$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq --arg version "${VERSION%.x}" -r '.offers | map(select(.version | startswith($version))) | sort_by(.version) | reverse | .[0].version')
		download_wp "${LATEST}"
		ln -sf "/usr/share/wptl/wordpress-${LATEST}" "/usr/share/wptl/wordpress-${VER}"
		ln -sf "/usr/share/wptl/wordpress-tests-lib-${LATEST}" "/usr/share/wptl/wordpress-tests-lib-${VER}"
		return
	else
		TESTS_TAG="tags/${VERSION}"
	fi

	if [ ! -d "/usr/share/wptl/wordpress-${VERSION}" ]; then
		if [ "${VERSION}" = "nightly" ]; then
			cd /wordpress
			wget -q https://wordpress.org/nightly-builds/wordpress-latest.zip
			unzip -q wordpress-latest.zip
			mv /usr/share/wptl/wordpress /usr/share/wptl/wordpress-nightly
			rm -f wordpress-latest.zip
			cd -
		else
			mkdir -p "/usr/share/wptl/wordpress-${VERSION}"
			wget -q "https://wordpress.org/wordpress-${VERSION}.tar.gz" -O - | tar --strip-components=1 -zxm -f - -C "/usr/share/wptl/wordpress-${VERSION}"
		fi
		wget -q https://raw.github.com/markoheijnen/wp-mysqli/master/db.php -O "/usr/share/wptl/wordpress-${VERSION}/wp-content/db.php"
	else
		echo "Skipping WordPress download"
	fi

	if [ ! -d "/usr/share/wptl/wordpress-tests-lib-${VERSION}" ]; then
		mkdir -p "/usr/share/wptl/wordpress-tests-lib-${VERSION}"
		svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}/tests/phpunit/includes/" "/usr/share/wptl/wordpress-tests-lib-${VERSION}/includes"
		svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}/tests/phpunit/data/" "/usr/share/wptl/wordpress-tests-lib-${VERSION}/data"
		rm -f "/usr/share/wptl/wordpress-tests-lib-${VERSION}/wp-tests-config-sample.php"
		wget -q "https://develop.svn.wordpress.org/${TESTS_TAG}/wp-tests-config-sample.php" -O "/usr/share/wptl/wordpress-tests-lib-${VERSION}/wp-tests-config-sample.php"
	else
		echo "Skipping WordPress test library download"
	fi
}

download_wp "${1:-latest}"
