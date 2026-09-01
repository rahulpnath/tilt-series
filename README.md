# Local Dev from First Principles — Docker, Tilt & Caddy

The workspace repo for the series. It holds the shared pieces — a `Tiltfile`
from Video 4, Caddy from Video 5 — and a `main/` folder holding a clone of each
app repo.

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

## You are at `v4-end`

One command, from here:

```sh
docker network create shopnet    # still once, outside any project
tilt up
```

Ten resources in one UI at <http://localhost:10350>, grouped by repo, each with
its own log stream, its own status and its own restart button. The four
`docker compose up` commands are gone; **the four `compose.yaml` files are not
touched.**

- <http://localhost:5173> — the storefront · <http://localhost:5174> — the admin app
- <http://localhost:5101/products> · <http://localhost:5102/orders>
- <http://localhost:15672> — RabbitMQ (shop / shop)

### What is actually here

```
tilt-series/
├── Tiltfile              ← includes each repo's Tiltfile
├── tilt/shared.Tiltfile  ← where a repo lives
└── main/
    ├── Shop.Catalog/Tiltfile
    ├── Shop.Orders/Tiltfile
    ├── Shop.Storefront/Tiltfile
    └── Shop.Admin/Tiltfile
```

Each repo's `Tiltfile` is the primitive: `cd main/Shop.Catalog && tilt up` runs
that repo on its own, and has to keep working — Video 6 builds worktrees on
exactly that. The workspace file is a loop over four `include()` calls.

`repo_dir()` prefers a checkout **beside this file** over the one in `main/`, so
a folder that carries its own copy of a repo runs that copy. Every group gets a
full stack from whatever subset it has.

> Copy this `Tiltfile` if you want it somewhere else — don't symlink it. Tilt
> resolves paths against the symlink's target, so it goes looking for repos next
> to the original.

### Why no compose file had to change

`include()` gives each Tiltfile its own working directory — the repo's — so
`docker/compose.yaml` and `context: ..` mean what you'd expect. And each repo
passes its own `project_name`, so Tilt runs **four separate compose projects**,
each with its own `--project-directory`:

```
shop              catalog-api  catalog-worker  catalog-sqlserver  catalog-rabbitmq
shop-orders       orders-api   orders-worker   orders-sqlserver   orders-rabbitmq
shop-storefront   storefront-web
shop-admin        admin-web
```

Two traps live in that list, and neither one errors loudly:

- **`project_name` is not optional.** Tilt does not read the `name:` key inside
  `compose.yaml`. Omit the argument and every included file collapses into one
  project named after the first repo's folder, resolving that repo's relative
  paths for all of them.
- **Resource names are global.** Catalog and Orders both have a `sqlserver` and
  a `rabbitmq`. Whichever loads second stops with `dc_resource named
  "rabbitmq" already exists` — hence `new_name=` in both repos' Tiltfiles.

### Now you can see it

Grouping ten containers in one place makes the duplication obvious for the first
time: **two SQL Servers and two RabbitMQs**, one per API repo. That's real, it's
the cost of one-repo-one-compose-file, and Video 8 is where it gets fixed.

`tilt down` stops everything and leaves the named volumes alone — `sql-data`
survives, exactly as `docker compose down` without `-v` would.

**Prerequisites at this tag:** Docker, [Tilt](https://docs.tilt.dev/install.html),
~8 GB of free RAM, and the `shopnet` network. Forget the network and Tilt shows
you the compose error in the failing resource's log:
`network shopnet declared as external, but could not be found`.

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
