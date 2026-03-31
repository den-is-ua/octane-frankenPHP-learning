# Laravel Octane + FrankenPHP (learning)

Small sandbox for learning **[Laravel Octane](https://laravel.com/docs/octane)** and comparing how the same Laravel app behaves behind **Nginx**, **Apache**, and **Octane** (FrankenPHP, Swoole, RoadRunner). Everything runs in Docker with **MySQL** and **Redis**.

## What’s in the box

- **Laravel** with **Octane** (FrankenPHP, Swoole, or RoadRunner)
- **Composer**: `spiral/roadrunner-http` + `spiral/roadrunner-cli` (RoadRunner / Octane)
- **Docker Compose** stacks (same app volume, shared DB/cache):

| Service | Role | Host port (default) |
|--------|------|---------------------|
| `nginx` | Nginx → **PHP-FPM** | `8080` |
| `apache` | **Apache** + `mod_php` | `8081` |
| `octane-frankenphp` | **Octane + FrankenPHP** | `8000` |
| `octane-swoole` | **Octane + Swoole** | `8001` |
| `octane-roadrunner` | **Octane + RoadRunner** | `8002` |
| `mysql` | MySQL 8.4 | `33060` → `3306` |
| `redis` | Redis 7 | `63790` → `6379` (override with `REDIS_PORT`) |

Set only the servers you need, or start everything:

```bash
docker compose up -d
```

If you renamed services (for example from the old `app` service), remove stale containers once:

```bash
docker compose down --remove-orphans
```

**RoadRunner:** the Linux `rr` binary is downloaded inside the `octane-roadrunner` container on first start (the entrypoint removes any host `rr` that might be the wrong OS/arch). The first boot can take a short while while RoadRunner is fetched.

## Run migrations (pick one PHP container)

```bash
docker compose exec octane-frankenphp php artisan migrate
```

## Shell in the FrankenPHP Octane container

```bash
./go-into-app
# or
docker compose exec octane-frankenphp bash
```

## Useful Octane commands

```bash
docker compose exec octane-frankenphp php artisan octane:frankenphp --help
docker compose exec octane-swoole php artisan octane:start --server=swoole --help
docker compose exec octane-roadrunner php artisan octane:start --server=roadrunner --help
```

## Load testing (`performance_test.sh`)

`performance_test.sh` fires many concurrent HTTP requests to **`http://127.0.0.1:<port>/concurrency`** by default (override the path with `PERF_PATH`). It prints **load averages** and **memory** before and after the run, plus **wall-clock / user / sys** time for the batch.

**Prerequisites:** Docker stacks are up (`docker compose up -d`) and the server you pick is listening on the port below.

```bash
chmod +x performance_test.sh   # once
./performance_test.sh --help
```

**Usage:** `performance_test.sh <server> [concurrent_requests]` — default **1000** requests.

| First argument | Stack | Default host port |
|----------------|-------|-------------------|
| `nginx` | Nginx + PHP-FPM | `8080` |
| `apache` | Apache + mod_php | `8081` |
| `franken` or `frankenphp` | Octane + FrankenPHP | `8000` |
| `swoole` | Octane + Swoole | `8001` |
| `roadmap` or `roadrunner` | Octane + RoadRunner | `8002` |

If you changed ports in Compose, use the same env vars as in `docker-compose.yml` (e.g. `NGINX_PORT`, `OCTANE_SWOOLE_PORT`).

**Examples:**

```bash
./performance_test.sh nginx
./performance_test.sh franken 500
PERF_PATH=/ ./performance_test.sh apache 200   # hit `/` instead of `/concurrency`
OCTANE_SWOOLE_PORT=9001 ./performance_test.sh swoole 2000
```

## Learn more

- [FrankenPHP — Laravel & Octane](https://frankenphp.dev/docs/laravel/)
- [Laravel Octane](https://laravel.com/docs/octane)
