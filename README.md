# Local Dev from First Principles — Docker, Tilt & Caddy

The workspace repo for the series. It holds the shared pieces — `infra/`, the
`Tiltfile`, Caddy from video 5 — and a `main/` folder holding a clone of each app
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

## You are at `v5-start`

The same tree as `v4-end` — video 5 starts here: one `tilt up`, and four apps on four
`localhost` ports, over plain HTTP. One command, from here:

```sh
for d in infra main/Shop.Catalog main/Shop.Orders; do echo 'SA_PASSWORD=P@ssw0rd!Demo1' > $d/.env; done

tilt up
```

Eight resources in one UI at http://localhost:10350 — grouped by repo, each with its own
status, its own log and a link to it. Infra starts first, then the four apps. The five
`docker compose up` commands are gone; **the five `compose.yaml` files are not touched.**

- http://localhost:5174 — Admin · http://localhost:5173 — the Storefront
- http://localhost:5101/products · http://localhost:5102/orders — the APIs
- http://localhost:15672 — RabbitMQ (`shop` / `shop`)

`tilt down` stops everything. It is `docker compose down` for every project, without `-v`,
so the database volume stays. Compose takes the projects down in no fixed order, so
`shopnet` is sometimes left behind with `Resource is still in use` — harmless; the next `up`
reuses it.

### What is here

```
tilt-series/
├── Tiltfile                     # includes each repo's Tiltfile; infra; the start order
├── bootstrap.sh
├── infra/
│   ├── compose.yaml             # shop-infra: sqlserver + rabbitmq, network `shopnet`
│   └── .env                     # you create this; gitignored
└── main/
    ├── Shop.Catalog/Tiltfile    ← github.com/rahulpnath/tilt-series-catalog     :5101
    ├── Shop.Orders/Tiltfile     ← github.com/rahulpnath/tilt-series-orders      :5102
    ├── Shop.Storefront/Tiltfile ← github.com/rahulpnath/tilt-series-storefront  :5173
    └── Shop.Admin/Tiltfile      ← github.com/rahulpnath/tilt-series-admin       :5174
```

Each repo's `Tiltfile` is the primitive: `cd main/Shop.Catalog && tilt up` runs that repo on
its own (with infra already up). The workspace file `include()`s the four, adds `infra/` as
one more `docker_compose()`, and declares the order:

```python
for app in ['catalog-api', 'catalog-worker', 'orders-api', 'orders-worker']:
    dc_resource(app, resource_deps=['sqlserver', 'rabbitmq'])
```

`resource_deps` orders the starts, and `wait=True` on infra is video 3's `--wait`: Tilt's
`docker compose up` for infra doesn't finish until both health checks pass, so the .NET apps
start against a database and a broker that are ready.

### Why no compose file had to change

`include()` runs each repo's Tiltfile in that repo's folder, so `compose.yaml` and `./src`
mean what they always did. And each repo passes its own `project_name`, so Tilt runs five
separate compose projects. Two things to know:

- **`project_name` is not optional.** Tilt does not read the `name:` key in `compose.yaml`.
  Leave the argument out and Tilt names the project after the folder — `shoporders` — and
  starts a second set of containers next to the first.
- **Resource names are global.** Catalog and Orders both have a service called `api`, and
  the Storefront and Admin both have `web`. The second one loaded stops with
  `Error in docker_compose: dc_resource named "api" already exists` — hence `new_name=` in
  every repo's Tiltfile. The service name in the compose file, and the container name, are
  unchanged.

Tilt watches the Tiltfiles, the compose files and the Dockerfiles. It does not watch your
source — the bind mounts and `dotnet watch` / Vite still do the reloading, exactly as before.

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/) and
[Tilt](https://docs.tilt.dev/install.html).

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
