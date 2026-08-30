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

## You are at `v2-start`

`main/Shop.Catalog` is **two** services now — `Shop.Catalog.Api` and
`Shop.Catalog.Worker` — and between them they need SQL Server and RabbitMQ.
Adding a product saves a row and publishes a `ProductCreated` event; the worker
handles it.

The Docker side hasn't moved since `v1-end`, and that's the problem. Video 1's
`docker run` still starts the API, but the API now needs a database and a broker
that aren't there, so it never serves a request. Starting Catalog by hand means
a network and four containers, in an order that matters:

```sh
docker network create shop-net
docker run -d --name sqlserver      --network shop-net ...
docker run -d --name rabbitmq       --network shop-net ...
docker run -d --name catalog-api    --network shop-net ...
docker run -d --name catalog-worker --network shop-net ...
```

The network comes first because Docker's **default bridge has no DNS** — without
a user-defined network, `sqlserver` resolves to nothing. Full commands, with
every flag, are in
[`main/Shop.Catalog/README.md`](main/Shop.Catalog/README.md).

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/
        ├── docker/
        │   ├── catalog-api.dev.Dockerfile
        │   └── catalog-worker.dev.Dockerfile
        └── src/
            ├── Shop.Catalog.Api/
            ├── Shop.Catalog.Contracts/     ← the message both sides share
            └── Shop.Catalog.Worker/
```

**Prerequisites at this tag:** Docker, and ~4 GB of free RAM — SQL Server is the
greedy one.

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
