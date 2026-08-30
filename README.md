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

## You are at `v3-end`

Three repos, three compose projects — and now one **shared external network**
that two of them join.

```sh
docker network create shopnet    # once, outside any project

docker compose -f main/Shop.Catalog/docker/compose.yaml up
docker compose -f main/Shop.Orders/docker/compose.yaml up
docker compose -f main/Shop.Storefront/docker/compose.yaml up
```

- <http://localhost:5173> — the storefront, now able to reach both APIs
- <http://localhost:5101/products> · <http://localhost:5102/orders>
- <http://localhost:15672> — RabbitMQ (shop / shop)

`shopnet` is created by hand and declared `external: true`, so Compose won't
create it for you. Forget it and `up` says so:

```
network shopnet declared as external, but could not be found
```

### The two failures had two different fixes

**api → api** was Docker DNS being per network. `catalog-api` and `orders-api`
both join `shopnet` and resolve each other by service name. They stay on their
own project networks too — the `networks:` list has to include `default`, or
each container loses its own SQL Server and RabbitMQ.

**browser → api** was never a Docker problem. `Shop.Storefront` does not join
`shopnet` and has no reason to: its `fetch` calls run on your machine, so they
use `http://localhost:5101` and the published ports. A dev CORS policy in both
APIs keeps the browser from blocking the cross-origin calls; Video 5 removes the
need for it.

### Three terminals

Which is the problem. Three repos means three `docker compose up`, three log
streams, and no single place that tells you what is actually running.

**Prerequisites at this tag:** Docker, ~8 GB of free RAM (two SQL Servers, one
per repo — nothing is shared until Video 8), and the `shopnet` network.

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
