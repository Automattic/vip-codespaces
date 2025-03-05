# VIP Codespaces

A development environment for WordPress VIP sites using GitHub Codespaces and VS Code Development Containers.

## Overview

VIP Codespaces provides a containerized development environment for WordPress VIP sites, making it easy to set up and maintain a consistent development environment across teams. It leverages GitHub Codespaces and VS Code (and forks) [Development Containers](https://containers.dev/) to provide a seamless development experience.

## Features

- **WordPress Development Environment**: Pre-configured with WordPress, MariaDB, Nginx, and PHP
- **WordPress Integration**: Includes VIP Go mu-plugins and VIP CLI
- **Development Tools**: Includes tools like WP-CLI, XDebug, phpMyAdmin, and Mailpit
- **Customizable**: Configure PHP version, WordPress version, and other settings
- **Elasticsearch Support**: Optional Elasticsearch integration
- **Memcached Support**: Optional Memcached integration
- **Cron Support**: Configurable WordPress cron jobs

## Getting Started

### Prerequisites

- GitHub account with access to GitHub Codespaces
- OR other IDEs supporting Dev Containers

### Using with GitHub Codespaces

1. We provide the `.devcontainer/devcontainer.json` in our [Skeleton template repository](https://github.com/Automattic/vip-go-skeleton/tree/production/.devcontainer). For older codebases, you will need to add the `.devcontainer/devcontainer.json` configuration to your WordPress VIP repository manually
2. Start a new Codespace from your repository
3. Wait for the environment to build and initialize
4. Access your WordPress site at the forwarded port (typically port 80)


### Using with VS Code/Cursor/Windsurf Development Containers

1. Add the `.devcontainer/devcontainer.json` configuration to your WordPress VIP project
2. Open the project in VS Code
3. Click on the Remote Containers extension icon and select "Reopen in Container"
4. Wait for the environment to build and initialize
5. Access your WordPress site at localhost

## Configuration

The development environment can be customized through the `devcontainer.json` file. Available options include:

- PHP version
- WordPress version
- WordPress domain
- WordPress multisite configuration
- VIP Go mu-plugins integration
- Development tools (Xdebug, phpMyAdmin, Mailpit, etc.)
- Elasticsearch and Memcached support
- Cron configuration

Example configuration:

```json
{
    "name": "WordPress VIP Development Environment",
    "image": "ghcr.io/automattic/vip-codespaces/alpine-base:latest",
    "features": {
        "ghcr.io/automattic/vip-codespaces/nginx:latest": {},
        "ghcr.io/automattic/vip-codespaces/php:latest": {
            "version": "8.0"
        },
        "ghcr.io/automattic/vip-codespaces/mariadb:latest": {},
        "ghcr.io/automattic/vip-codespaces/wordpress:latest": {
            "version": "latest",
            "multisite": "false"
        },
        "ghcr.io/automattic/vip-codespaces/vip-go-mu-plugins:latest": {
            "enabled": "true"
        }
    }
}
```

## Available Features

The environment is built using a modular approach with various features that can be enabled or disabled:

- **base**: Base feature for VIP Codespaces
- **nginx**: Nginx web server
- **php**: PHP with configurable version
- **mariadb**: MariaDB database server
- **wordpress**: WordPress core
- **wp-cli**: WordPress CLI
- **vip-go-mu-plugins**: WordPress VIP MY-plugins
- **vip-cli**: VIP CLI
- **elasticsearch**: Elasticsearch server
- **memcached**: Memcached server
- **xdebug**: Xdebug for PHP debugging
- **phpmyadmin**: phpMyAdmin for database management
- **mailpit**: Mail testing tool
- **cron**: Cron job support

## Port Forwarding

The environment forwards several ports for accessing different services:

- **80**: WordPress application
- **81**: phpMyAdmin
- **8025**: Mailpit web interface
- **9003**: Xdebug

## Contributing

Contributions to VIP Codespaces are welcome. Please follow the standard GitHub workflow:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the terms of the GPL v2+ license.

## Support

For support with VIP Codespaces, please open an issue on the GitHub repository. 