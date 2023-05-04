<?php
$media_redirect_url  = $argv[1] ?? '';
$only_images_with_qs = ( $argv[2] ?? '' ) !== 'false';
?>
<?php if ( $only_images_with_qs ) : ?>
location ^~ /wp-content/uploads/ {
    expires max;
    log_not_found off;

<?php if ( $media_redirect_url ) : ?>
    if (!-f $request_filename) {
        rewrite ^/(.*)$ <?=$media_redirect_url?>/$1 redirect;
    }
<?php endif; ?>

    include fastcgi_params;
    fastcgi_param DOCUMENT_ROOT /usr/share/webapps/photon;
    fastcgi_param SCRIPT_FILENAME /usr/share/webapps/photon/index.php;
    fastcgi_param SCRIPT_NAME /index.php;

    if ($request_uri ~* \.(gif|jpe?g|png)\?) {
        fastcgi_pass photon:9000;
    }
}
<?php else : ?>
location ^~ /wp-content/uploads/ {
    expires max;
    log_not_found off;

<?php if ( $media_redirect_url ) : ?>
    try_files $uri @prod_site;
<?php endif; ?>

    location ~* \.(gif|jp?eg|png)$ {
        fastcgi_pass photon:9000;
        include fastcgi_params;
        fastcgi_param DOCUMENT_ROOT /usr/share/webapps/photon;
        fastcgi_param SCRIPT_FILENAME /usr/share/webapps/photon/index.php;
        fastcgi_param SCRIPT_NAME /index.php;
    }
}

<?php if ( $media_redirect_url ) : ?>
location @prod_site {
    rewrite ^/(.*)$ <?=$media_redirect_url?>/$1 redirect;
}
<?php endif; ?>
<?php endif; ?>
