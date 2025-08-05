
# Playwright (playwright)

Sets up Playwright into the Dev Environment

## Example Usage

```json
"features": {
    "ghcr.io/Automattic/vip-codespaces/playwright:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| enabled | Enable Playwright | boolean | true |
| version | Playwright version to install | string | latest |

## Customizations

### VS Code Extensions

- `ms-playwright.playwright`

This feature is available only for Debian-based containers.

Alpine-based containers are **not** supported because the browsers used by Playwright are built against `libc`, not `musl`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Automattic/vip-codespaces/blob/main/features/src/playwright/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
