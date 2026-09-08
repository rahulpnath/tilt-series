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

## You are at `v1.3-start`

`main/Shop.Storefront` arrives — **storefront-web**, a Vite + React app listing the shop's
products. It has no Docker config yet; that is what video 1.3 builds.

```sh
cd main/Shop.Storefront/src
npm install
npm run dev
```

Then open http://localhost:5173. It needs **Node 24** on your machine — which is the point
1.3 opens on.

`main/Shop.Catalog` is unchanged from `v1.2-end`; it carries this tag so `bootstrap.sh`
still clones it here.

```
tilt-series/
├── bootstrap.sh
└── main/
    ├── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog
    │   ├── catalog-api.Dockerfile        # to ship:    aspnet:10.0, 340 MB
    │   ├── catalog-api.dev.Dockerfile    # to develop: sdk:10.0 + watch
    │   ├── .dockerignore
    │   └── src/
    └── Shop.Storefront/         ← github.com/rahulpnath/tilt-series-storefront
        └── src/                          # Vite + React, no Docker yet
            ├── package.json
            ├── vite.config.js
            └── src/
```

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/)
for Catalog, and [Node 24](https://nodejs.org/) for the Storefront. By the end of 1.3 the
Storefront needs Docker only.

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
