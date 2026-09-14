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

---

## You are at `v2-end`

`main/Shop.Catalog` has a **`compose.yaml`** describing all four of its containers — SQL
Server, RabbitMQ, the API and the worker. The runbook of `docker run` commands is gone.

```sh
cd main/Shop.Catalog
echo 'SA_PASSWORD=P@ssw0rd!Demo1' > .env    # not committed; Compose reads it
docker compose up
```

`main/Shop.Storefront` is **skipped at this tag** — video 1.3 introduces it, and it
publishes after this one. `bootstrap.sh` says so and carries on.

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog
        ├── compose.yaml                  # the four containers, one file
        ├── .env                          # you create this; gitignored
        ├── catalog-api.dev.Dockerfile    # sdk:10.0 + watch
        ├── catalog-worker.dev.Dockerfile # same, for the worker
        ├── catalog-api.Dockerfile        # to ship: aspnet:10.0, 340 MB (unused here)
        ├── .dockerignore
        └── src/
            ├── Shop.Catalog.Api/         # EF Core + Rebus publish
            ├── Shop.Catalog.Contracts/   # the ProductCreated message
            └── Shop.Catalog.Worker/      # subscribes and logs
```

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/)
only. The .NET SDK, SQL Server and RabbitMQ all run in containers.

---

## The series

1. **Docker core & the dev container** — image vs container, a Dockerfile, bind-mounting your source, `dotnet watch`
2. **Compose** — one file instead of a runbook of `docker run` commands
3. **Names & networking** — how one container finds another, and why `localhost` lies
4. **Tilt** — one control tower over four repos' compose files
5. **Caddy** — one HTTPS front door, and the end of CORS
6. **Many worktrees at once** — a full stack per branch, running side by side
7. **Dev tooling** — worktrunk, herdr and hunk, once doing it by hand hurts
8. **Optimizations & gotchas** — share what's shareable, and when not to

Each video's repo state is a tag: `v1-start`, `v1-end`, `v2-start`, … `v8-end`.
