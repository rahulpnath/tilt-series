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

## You are at `v1-start`

One repo, and **no Docker anywhere**. `main/Shop.Catalog` is a .NET 10 minimal
API that runs the way every .NET app you have ever cloned runs:

```sh
cd main/Shop.Catalog/src
dotnet run --project Shop.Catalog.Api

# in another terminal
curl http://localhost:5101/
curl http://localhost:5101/products
```

Which works — provided your machine happens to have the .NET 10 SDK on it.
That's the problem Video 1 starts from.

```
tilt-series/
├── bootstrap.sh
└── main/
    └── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog
        └── src/
            ├── Shop.Catalog.slnx
            └── Shop.Catalog.Api/
```

**Prerequisites at this tag:** the [.NET 10 SDK](https://dotnet.microsoft.com/download).
Docker arrives at `v1-end`.

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
