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

## You are at `v1.2-end`

Both apps now run in dev containers with hot reload — the .NET one and the
React one.

```sh
cd main/Shop.Storefront
docker build -t shop-storefront-web:dev -f docker/storefront-web.dev.Dockerfile .

docker run --rm -it -p 5173:5173 --name shop-storefront-web \
  -v "$PWD/src/src:/app/src" \
  shop-storefront-web:dev

# http://localhost:5173
```

Edit `src/src/App.jsx`, save, and the browser updates without a reload.

Two traps are specific to this side, and both fail **silently**:

- **Vite binds loopback.** Inside a container that means the container itself,
  so the published port forwards to nothing and the page never loads.
  `server.host: true` / `--host` fixes it.
- **`node_modules` through the bind mount.** Mounting your whole app folder
  over `/app` hides the image's install, and a host `node_modules` carries
  binaries built for the wrong platform. The usual patch — a second
  `-v /app/node_modules` — leaves an empty root-owned folder in your working
  tree on a fresh clone. Mounting `src/src` alone avoids both.

```
tilt-series/
├── bootstrap.sh
└── main/
    ├── Shop.Catalog/
    │   └── docker/catalog-api.dev.Dockerfile
    └── Shop.Storefront/
        ├── .dockerignore
        └── docker/storefront-web.dev.Dockerfile
```

**Prerequisites at this tag:** Docker. Node and the .NET SDK are both optional
now — they live in the images.

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
