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

## You are at `v1.2-end`

`main/Shop.Catalog` now has a **second Dockerfile, for development**. The one
from `v1-end` builds the image you'd ship; this one runs the app from source
with your working folder mounted in, so an edit shows up without a rebuild:

```sh
cd main/Shop.Catalog
docker build -f catalog-api.dev.Dockerfile -t catalog-api:dev .
docker run --rm -it -p 5101:5101 --name catalog-api \
  -v "$PWD/src:/src" \
  catalog-api:dev

# in another terminal
curl http://localhost:5101/
```

Edit `src/Shop.Catalog.Api/Program.cs` and curl again — `dotnet watch`, running
inside the container, rebuilds and restarts the app on its own.

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog
        ├── catalog-api.Dockerfile        # to ship:    aspnet:10.0, 340 MB
        ├── catalog-api.dev.Dockerfile    # to develop: sdk:10.0 + watch
        ├── .dockerignore
        └── src/
            ├── Shop.Catalog.slnx
            └── Shop.Catalog.Api/
```

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/).
Still no .NET SDK — it's in the image now.

That `docker run` is already long, and there's only one container so far. Video
2 replaces it with Compose.

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
