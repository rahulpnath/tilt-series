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

## You are at `v2-end`

One file, one command:

```sh
cd main/Shop.Catalog
docker compose -f docker/compose.yaml up
```

Compose builds both images, creates the network, starts SQL Server and RabbitMQ,
**waits for SQL to pass a healthcheck**, then starts the API and worker. Hot
reload still works, now for both .NET services at once.

- <http://localhost:5101/products> — the API
- <http://localhost:15672> — RabbitMQ management (shop / shop)

SQL Server publishes no port at all: the API reaches it across the network
Compose made, and nothing on your machine needs to.

```
tilt-series/
└── main/
    └── Shop.Catalog/
        ├── docker/
        │   ├── compose.yaml              ← everything, in one file
        │   ├── .env                      ← the SA password, written once
        │   ├── catalog-api.dev.Dockerfile
        │   └── catalog-worker.dev.Dockerfile
        └── src/
```

The details — the project name, why service names resolve, `${SA_PASSWORD}`
substitution, and what `depends_on` does and doesn't promise — are in
[`main/Shop.Catalog/README.md`](main/Shop.Catalog/README.md).

**Prerequisites at this tag:** Docker, and ~4 GB of free RAM for SQL Server.

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
