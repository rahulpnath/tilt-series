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

## You are at `v4-start`

A fourth repo. `Shop.Admin` is a second Vite app on **5174**, in its own compose
project, reading both APIs and writing to neither. Nothing else changed — the
other three repos are byte-for-byte what they were at `v3-end`.

```sh
docker network create shopnet    # once, outside any project

docker compose -f main/Shop.Catalog/docker/compose.yaml up
docker compose -f main/Shop.Orders/docker/compose.yaml up
docker compose -f main/Shop.Storefront/docker/compose.yaml up
docker compose -f main/Shop.Admin/docker/compose.yaml up
```

- <http://localhost:5173> — the storefront
- <http://localhost:5174> — the admin app
- <http://localhost:5101/products> · <http://localhost:5102/orders>
- <http://localhost:15672> — RabbitMQ (shop / shop)

### Four terminals

Which is the problem this tag exists to show. Four `docker compose up` commands,
in an order that matters because `shopnet` has to exist first, producing **ten
containers** across four log streams — and no single place that says what is
running.

Kill one container and nothing tells you. The first thing you see is a fetch
failing in the browser, and then you go hunting through four terminals for which
of the ten it was.

That hunt is what Video 4 replaces.

**Prerequisites at this tag:** Docker, ~8 GB of free RAM (two SQL Servers, one
per API repo — nothing is shared until Video 8), and the `shopnet` network.

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
