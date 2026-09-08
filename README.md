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

## You are at `v2-start`

`main/Shop.Catalog` grew the dependencies it deliberately didn't have before. The API
writes to **SQL Server** and publishes a message with **Rebus**; a new
**`Shop.Catalog.Worker`** subscribes to it. There is no Docker configuration for any of
it yet — that is what video 2 builds.

Four things have to be running, in order, before the app does anything:

```sh
docker run -d --name sqlserver -p 1433:1433 \
  -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD='P@ssw0rd!Demo1' \
  mcr.microsoft.com/mssql/server:2022-latest

docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=shop -e RABBITMQ_DEFAULT_PASS=shop \
  rabbitmq:3-management

cd main/Shop.Catalog
dotnet run --project src/Shop.Catalog.Worker
dotnet run --project src/Shop.Catalog.Api
```

`main/Shop.Storefront` is **skipped at this tag** — video 1.3 introduces it, and it
publishes after this one. `bootstrap.sh` says so and carries on.

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog
        ├── catalog-api.Dockerfile        # to ship:    aspnet:10.0, 340 MB
        ├── catalog-api.dev.Dockerfile    # to develop: sdk:10.0 + watch
        ├── .dockerignore
        └── src/
            ├── Shop.Catalog.Api/         # + EF Core, + Rebus publish
            ├── Shop.Catalog.Contracts/   # the ProductCreated message
            └── Shop.Catalog.Worker/      # subscribes and logs
```

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/)
and the [.NET 10 SDK](https://dotnet.microsoft.com/download). SQL Server and RabbitMQ run
as containers; nothing else is installed on your machine.

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
