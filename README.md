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

## You are at `v1-end`

`main/Shop.Catalog` now carries a **dev image**: the .NET SDK, your `src`
folder mounted into it, and `dotnet watch` recompiling on every save. Nothing
about the API changed — what changed is that it no longer needs a .NET SDK on
your machine.

```sh
cd main/Shop.Catalog
docker build -t shop-catalog-api:dev -f docker/catalog-api.dev.Dockerfile .

docker run --rm -it -p 5101:5101 --name shop-catalog-api \
  -v "$PWD/src:/src" \
  shop-catalog-api:dev

curl http://localhost:5101/
```

Now edit `src/Shop.Catalog.Api/Program.cs`, change the string on `/`, save, and
curl again — new response, no rebuild. The container is compiling your editor's
output.

Only your source is mounted. The image sets `ArtifactsPath=/artifacts`, so the
container compiles to a path inside itself and never writes `obj/` or `bin/`
into your tree — `main/Shop.Catalog/README.md` has the long version.

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/
        ├── .dockerignore
        ├── docker/catalog-api.dev.Dockerfile
        └── src/
```

**Prerequisites at this tag:** Docker. The .NET SDK is now optional — it lives
in the image.

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
