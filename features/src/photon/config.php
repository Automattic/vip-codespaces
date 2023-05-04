<?php

define( 'OPTIPNG', '/usr/bin/optipng' );
define( 'PNGQUANT', '/usr/bin/pngquant' );
define( 'PNGCRUSH', '/usr/bin/pngcrush' );
define( 'CWEBP', '/usr/bin/cwebp' );
define( 'JPEGOPTIM', '/usr/bin/jpegoptim' );
define( 'JPEGTRAN', '/usr/bin/jpegtran' );

if ( function_exists( 'add_filter' ) ) {
	add_filter( 'override_raw_data_fetch', function ( $_overridden_data, $url ) {
		global $remote_image_max_size;
		if ( preg_match( '!^https?://wp-content/uploads/!', $url ) ) {
			$prefix = realpath( '/wp/wp-content/uploads/' );
			$path   = realpath( preg_replace( '!^https?://!', '/wp/', $url ) );
			if ( $prefix && str_starts_with( $path, $prefix ) ) {
				if ( isset( $remote_image_max_size ) && $remote_image_max_size > 0 ) {
					$size = filesize( $path );
					if ( $size > $remote_image_max_size ) {
						return false;
					}
				}

				return file_get_contents( $path );
			}
		}

		return false;
	}, 10, 2 );
}
