# Hosting the API on `vitabu.africa` (fixes CORS + 404)

## What is going wrong

If the browser shows:

- **CORS**: *No `Access-Control-Allow-Origin` header*
- **Network**: **`404 Not Found`** on `POST https://vitabu.africa/api/...`

then the request is **usually not reaching Laravel**. Typical causes:

1. **Document root** points to an empty folder, a static `index.html`, or the Laravel project root **without** correct front-controller routing.
2. **Nginx / OpenLiteSpeed / LiteSpeed** is used and **`.htaccess` is ignored** — Apache rules in this repo do nothing until you add equivalent server config.
3. The API is deployed under another path (e.g. `https://vitabu.africa/something/public/...`) but the app calls `https://vitabu.africa/api/...`.

Until `https://vitabu.africa/api/general_setting` is handled by Laravel, **no PHP middleware (including CORS) can run** for that URL.

## Quick check (from any PC)

```bash
curl.exe -sI -X OPTIONS "https://vitabu.africa/api/general_setting" ^
  -H "Origin: https://vitabu.online" ^
  -H "Access-Control-Request-Method: POST"
```

- **Good:** `404` from Laravel is rare for OPTIONS; you more often see `204`/`200` and `Access-Control-Allow-Origin` (once CORS is configured).
- **Bad:** `404` with **`content-type: text/html`** and **no** Laravel — static/host default page → fix hosting below.

## Recommended setup (cPanel / Apache)

1. Set the domain’s **document root** to the Laravel **`public`** directory, e.g.  
   `.../admin_panel/public`
2. Ensure **`mod_rewrite`** is enabled.
3. Upload the full `admin_panel` tree; only `public` should be web-accessible for that vhost.

## Nginx example (API on same domain)

```nginx
server {
    server_name vitabu.africa;
    root /path/to/admin_panel/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

(Adjust `fastcgi_pass` / PHP version for your server.)

## After Laravel is reachable

1. Run on the server: `php artisan config:clear && php artisan route:clear && php artisan cache:clear`
2. Confirm routes: `php artisan route:list | findstr general_setting` (Windows) or `grep general_setting`.
3. Optional: keep `ForceCorsHeaders` + `config/cors.php` in sync with `https://vitabu.online` (and any staging domains).

## If the API must live on another URL

Update the Flutter `baseurl` in `yourappname/lib/utils/constant.dart` to match the **real** API base (e.g. `https://api.vitabu.africa/api/`), rebuild web, and redeploy.
