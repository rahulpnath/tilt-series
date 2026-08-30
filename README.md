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

## You are at `v1.2-start`

`main/Shop.Storefront` has arrived: a Vite + React app on :5173 showing a
static product list. It calls no API — that happens in video 3.

```sh
cd main/Shop.Storefront/src
npm install
npm run dev
# http://localhost:5173
```

Catalog hasn't moved since `v1-end`. The storefront is deliberately in the state
Catalog was in at `v1-start` — running straight on your machine, because your
machine happens to have the right Node.

```
tilt-series/
├── bootstrap.sh
└── main/
    ├── Shop.Catalog/           ← already containerized (v1-end)
    └── Shop.Storefront/        ← new, not containerized yet
        └── src/
```

**Prerequisites at this tag:** Node, plus Docker if you want to run Catalog.

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
