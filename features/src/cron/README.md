
# Cron (cron)

Enables cron in the Dev Environment

## Example Usage

```json
"features": {
    "ghcr.io/Automattic/vip-codespaces/cron:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| enabled | Enable cron | boolean | false |
| run_wp_cron | Run wp-cron.php from cron | boolean | false |
| wp_cron_schedule | Interval for wp-cron.php | string | */15 * * * * |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Automattic/vip-codespaces/blob/main/features/src/cron/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
