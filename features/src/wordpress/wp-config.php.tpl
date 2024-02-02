<?php

define( 'DB_NAME', '${WP_DATABASE}' );
define( 'DB_USER', '${WP_USERNAME}' );
define( 'DB_PASSWORD', '${WP_PASSWORD}' );
define( 'DB_HOST', '${WP_DBHOST}' );

define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', 'utf8mb4_unicode_520_ci' );

$table_prefix = 'wp_';

$memcached_servers = array (
  'default' =>
  array (
    0 => '127.0.0.1:11211',
  ),
);

if ( ! defined( 'WP_DEBUG' ) ) {
    define( 'WP_DEBUG', true );
}

if ( ! defined( 'WP_DEBUG_LOG' ) ) {
    define( 'WP_DEBUG_LOG', '/wp/log/debug.log' );
}

if ( ! defined( 'WP_DEBUG_DISPLAY' ) ) {
    define( 'WP_DEBUG_DISPLAY', false );
}

require( __DIR__ . '/wp-config-defaults.php' );

/* That's all, stop editing! Happy blogging. */
