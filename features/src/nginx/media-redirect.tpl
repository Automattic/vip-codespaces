location ~* /wp-content/uploads {
    expires max;
    log_not_found off;
    try_files $uri @prod_site;
}

location @prod_site {
    rewrite ^/(.*)$ ${MEDIA_REDIRECT_URL}/$1 redirect;
}
