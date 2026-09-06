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

## You are at `v1-end`

`main/Shop.Catalog` now has a **Dockerfile**. It's the same .NET 10 minimal API
as at `v1-start`, except it no longer needs the .NET SDK on your machine — only
Docker:

```sh
cd main/Shop.Catalog
docker build -f catalog-api.Dockerfile -t catalog-api .
docker run -d -p 5101:8080 catalog-api

# in another terminal
curl http://localhost:5101/products
```

It's a multi-stage build: `sdk:10.0` compiles the app, `aspnet:10.0` runs it,
and the SDK never ships. 340 MB instead of 1.25 GB.

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog
        ├── catalog-api.Dockerfile
        ├── .dockerignore
        └── src/
            ├── Shop.Catalog.slnx
            └── Shop.Catalog.Api/
```

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/).
The .NET SDK is optional from here — that's the whole point of the tag.

No bind mount and no `dotnet watch` yet: this image carries no SDK, so a code
change means building the image again. `v1.2-end` adds a dev image that fixes
that.

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
