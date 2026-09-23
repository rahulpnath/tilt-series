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

## You are at `v5-end`

One command, from here:

```sh
for d in infra main/Shop.Catalog main/Shop.Orders; do echo 'SA_PASSWORD=P@ssw0rd!Demo1' > $d/.env; done

tilt up
```

Ten resources in one UI at http://localhost:10350. Every app now sits behind **Caddy** — one
more container, in `caddy/`, and the only thing publishing a port for the apps (80 and 443).
Each app has a name, over HTTPS:

- https://storefront.localhost — the Storefront · https://admin.localhost — Admin
- https://catalog.localhost/products · https://orders.localhost/orders — the APIs
- http://localhost:15672 — RabbitMQ (`shop` / `shop`) · SQL Server on `localhost,1433`

`*.localhost` names reach your own machine in every browser, and in `curl`, with no hosts
entry. The first time, the browser warns: Caddy signs these with a certificate authority of its
own. Trust it once — next section — and the warning is gone for every name it serves.

### Trust Caddy's root certificate (once)

```sh
cd caddy
docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt ./root.crt
```

The root lives in the `caddy-data` volume, so it survives `tilt down` / `tilt up`; remove the
volume and Caddy makes a new one, which you trust again.

- **Windows** — double-click `root.crt` → *Install Certificate* → *Current User* → *Place all
  certificates in the following store* → *Trusted Root Certification Authorities*, or
  `certutil -user -addstore Root root.crt`. Chrome and Edge read this store. From WSL2 the file
  is at `\\wsl.localhost\<distro>\home\…\caddy\root.crt`.
- **macOS** — `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain root.crt`
- **Linux** — `sudo cp root.crt /usr/local/share/ca-certificates/caddy-local.crt && sudo update-ca-certificates`;
  Chrome on Linux keeps its own store: `certutil -d sql:$HOME/.pki/nssdb -A -t C -n caddy-local -i root.crt`
- **Firefox** keeps its own store on every OS — set `security.enterprise_roots.enabled` to `true`
  in `about:config` and it uses the system's.

Skip this and the page warning can be clicked past, but the Storefront's `fetch` calls to the
APIs fail silently — there is no click-through for a `fetch`.

### What is here

```
tilt-series/
├── Tiltfile                     # includes each repo's Tiltfile; infra; caddy; the start order
├── bootstrap.sh
├── infra/
│   ├── compose.yaml             # shop-infra: sqlserver + rabbitmq, network `shopnet`
│   └── .env                     # you create this; gitignored
├── caddy/
│   ├── compose.yaml             # shop-caddy: caddy:2 on 80 + 443, on `shopnet`
│   ├── Caddyfile                # one block per name → the container's alias and port
│   └── root.crt                 # exported by you; gitignored
└── main/
    ├── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog     catalog.localhost
    ├── Shop.Orders/             ← github.com/rahulpnath/tilt-series-orders      orders.localhost
    ├── Shop.Storefront/         ← github.com/rahulpnath/tilt-series-storefront  storefront.localhost
    └── Shop.Admin/              ← github.com/rahulpnath/tilt-series-admin       admin.localhost
```

### What changed, and why

- **`caddy/compose.yaml`** — one service from the official image. It publishes 80 and 443, mounts
  the Caddyfile read-only, and keeps its certificates in a volume. Its `default` network *is*
  `shopnet` (declared `external`, infra owns it): Caddy has nothing private to talk to, so it
  needs no network of its own. `--watch` on the command makes Caddy reload the Caddyfile on save.
- **`caddy/Caddyfile`** — four blocks, one per name, each a `reverse_proxy` to that app's alias
  and port on `shopnet`. No `tls` line: Caddy treats `.localhost` names as local and signs them
  with its internal authority by itself, and it redirects `http://` to `https://` on its own.
- **Storefront and Admin join `shopnet`** with the aliases `storefront-web` and `admin-web` —
  Caddy reaches them by name, and `web` alone would collide on the shared network. Their API
  addresses become `https://catalog.localhost` and `https://orders.localhost`.
- **The apps' published ports are gone** — 5101, 5102, 5173, 5174. Nothing outside Docker needs
  them: the browser goes through Caddy, and containers always went by name. Tilt's links came
  from those ports, so each repo's `Tiltfile` now carries `links=` instead.
- **The workspace `Tiltfile`** adds Caddy as one more `docker_compose()`, and the `resource_deps`
  loop now covers everything on `shopnet`, Caddy and the two React apps included.
- **CORS stays** in both APIs. The pages and the APIs are different origins — `storefront.localhost`
  and `catalog.localhost` — exactly as they will be when deployed.

`tilt down` stops everything without `-v`, so the database and Caddy's certificates stay.

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/) and
[Tilt](https://docs.tilt.dev/install.html).

---

## The series

1. **Docker core & the dev container** — image vs container, a Dockerfile, bind-mounting your source, `dotnet watch`
2. **Compose** — one file instead of a runbook of `docker run` commands
3. **Names & networking** — how one container finds another, and why `localhost` lies
4. **Tilt** — one control tower over four repos' compose files
5. **Caddy** — one HTTPS front door, a name per app
6. **Many worktrees at once** — a full stack per branch, running side by side
7. **Dev tooling** — worktrunk, herdr and hunk, once doing it by hand hurts
8. **Optimizations & gotchas** — share what's shareable, and when not to

Each video's repo state is a tag: `v1-start`, `v1-end`, `v2-start`, … `v8-end`.
