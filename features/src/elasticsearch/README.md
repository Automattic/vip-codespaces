
# Elasticsearch (elasticsearch)

Sets up Elasticsearch into the Dev Environment

## Example Usage

```json
"features": {
    "ghcr.io/Automattic/vip-codespaces/elasticsearch:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| enabled | Enable Elasticsearch | boolean | true |
| version | Elasticsearch version to install | string | 7.17.28 |
| installDataToWorkspaces | Set Elasticseatch data directory to /workspaces/es-data to persist data between container rebuilds (GHCS) | boolean | false |
| install-runit-service | Whether to install a runit service for Elasticsearch | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Automattic/vip-codespaces/blob/main/features/src/elasticsearch/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
