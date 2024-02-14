
# WordPress (wordpress)

Sets up WordPress into the Dev Environment

## Example Usage

```json
"features": {
    "ghcr.io/Automattic/vip-codespaces/wordpress:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | WordPress version to install | string | latest |
| moveUploadsToWorkspaces | Set the uploads directory to /workspaces/uploads to persist data across container rebuilds (GHCS) | boolean | false |
| multisite | Install WordPress as a multisite | boolean | false |
| multisiteStyle | Multisite style to use | string | subdirectory |
| domain | Domain to use for the site | string | localhost |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Automattic/vip-codespaces/blob/main/features/src/wordpress/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
