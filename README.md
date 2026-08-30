# Local Dev from First Principles — Docker, Tilt & Caddy

The workspace repo for the series. It holds the shared pieces (a Tiltfile and
Caddy arrive in later videos) and a `main/` folder holding a clone of each app
repo.

Every video has a **`vN-start` and a `vN-end` tag**, and the same tag exists in
this repo *and* in every app repo. So you can start from any video:

```sh
git clone https://github.com/rahulpnath/tilt-series
cd tilt-series
./bootstrap.sh v1-start
```

`bootstrap.sh` puts this repo on the tag and clones each app repo at the same
tag into `main/`. Repos the series hasn't introduced yet are skipped.

A tag isn't a branch, so every repo lands *detached* at it — which is what you
want for reading along. If you start making changes you'd like to keep, give
them a branch: `git checkout -b my-changes`.

---

## You are at `v3-start`

**Three repos now**, each with its own compose file, its own project name, and —
this is the point — its own network:

| | | |
|---|---|---|
| `main/Shop.Catalog` | `catalog-api` :5101 + `catalog-worker` | SQL, RabbitMQ |
| `main/Shop.Orders` | `orders-api` :5102 + `orders-worker` | SQL, RabbitMQ |
| `main/Shop.Storefront` | `storefront-web` :5173 | calls both APIs from the browser |

Start all three — three commands, three terminals:

```sh
docker compose -f main/Shop.Catalog/docker/compose.yaml up
docker compose -f main/Shop.Orders/docker/compose.yaml up
docker compose -f main/Shop.Storefront/docker/compose.yaml up
```

Everything comes up. Nothing can talk to anything else, in **two different
ways**:

```sh
# api -> api, server-side, over Docker's network
curl http://localhost:5102/catalog-check
# {"reached":"http://catalog-api:5101","ok":false,"error":"Name or service not known"}
```

```
# browser -> api, from http://localhost:5173
Could not reach catalog-api at http://catalog-api:5101 — Failed to fetch
```

Same error text, completely different causes. One is Docker DNS being per
network; the other is your browser not being on a Docker network at all. Video 3
is about telling them apart and fixing each properly.

A dev CORS policy already ships in both APIs, so that isn't what's failing here.

**Prerequisites at this tag:** Docker, and ~8 GB of free RAM — there are two SQL
Servers now, one per repo. Nothing is shared until Video 8.

---

## The series

1. **Docker core** — image vs container, the registry, running someone else's image
   - **1.1 Your .NET app in a container** — a dev Dockerfile, bind-mounting your source, `dotnet watch`
   - **1.2 Your React app in a container** — the same for Vite, where the traps are different
2. **Compose** — one file instead of a runbook of `docker run` commands
3. **Names & networking** — how one container finds another, and why `localhost` lies
4. **Tilt** — one control tower over four repos' compose files
5. **Caddy** — one HTTPS front door, and the end of CORS
6. **Many worktrees at once** — a full stack per branch, running side by side
7. **Dev tooling** — worktrunk, herdr and hunk, once doing it by hand hurts
8. **Optimizations & gotchas** — share what's shareable, and when not to

Each video's repo state is a tag: `v1-start`, `v1-end`, `v1.2-start`, `v1.2-end`,
`v2-start`, … `v8-end`. Video 1 needs no repo at all — every image in it is
someone else's — so the `v1-*` pair belongs to 1.1.
