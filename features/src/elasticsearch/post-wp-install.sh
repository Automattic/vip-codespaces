#!/bin/sh

if [ -e /etc/service/elasticsearch ] && wp cli has-command vip-search; then
    echo "Waiting for Elasticsearch to come online..."
    second=0
    while ! curl -s 'http://127.0.0.1:9200/_cluster/health' > /dev/null && [ "${second}" -lt 60 ]; do
        sleep 1
        second=$((second+1))
    done
    status="$(curl -s 'http://127.0.0.1:9200/_cluster/health?wait_for_status=yellow&timeout=60s' | jq -r .status)"
    if [ "${status}" != 'green' ] && [ "${status}" != 'yellow' ]; then
        echo "WARNING: Elasticsearch has failed to come online"
    fi

    wp vip-search index --skip-confirm --setup
fi
