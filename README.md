# Laravel Octane + FrankenPHP (learning)

Small sandbox for learning **[Laravel Octane](https://laravel.com/docs/octane)** with the **[FrankenPHP](https://frankenphp.dev/)** application server. The app runs in Docker so you can focus on Octane behaviour (workers, long-lived requests, caching) without wiring PHP locally.

## What’s in the box

- **Laravel** with **Octane** (`OCTANE_SERVER=frankenphp`)
- **FrankenPHP** as the Octane backend (Caddy + PHP in one process)
- **Docker Compose**: app (Octane), **MySQL 8.4**, **Redis 7**
- PHP **8.4** in the app image (required by current Laravel)

## Run it

```bash
docker compose up -d
```

- App: [http://localhost:8000](http://localhost:8000) (override with `APP_PORT`)
- MySQL: host port `33060` → container `3306`
- Redis: host port `63790` → container `6379`

After changing code or dependencies:

```bash
docker compose exec app php artisan migrate
```

## Useful commands (inside the app container)

```bash
docker compose exec app php artisan octane:frankenphp --help
docker compose exec app php artisan octane:status
```

The Compose service already starts Octane with FrankenPHP bound to `0.0.0.0:8000`.

## Learn more

- [FrankenPHP — Laravel & Octane](https://frankenphp.dev/docs/laravel/)
- [Laravel Octane](https://laravel.com/docs/octane)
