
# MariaDB (mariadb)

Sets up MariaDB into the Dev Environment

## Example Usage

```json
"features": {
    "ghcr.io/Automattic/vip-codespaces/mariadb:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installDatabaseToWorkspaces | Set MariaDB data directory to /workspaces/mysql-data to persist data between container rebuilds (GHCS) | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Automattic/vip-codespaces/blob/main/features/src/mariadb/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
