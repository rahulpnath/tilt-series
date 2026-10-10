# Local Dev from First Principles — Docker, Tilt & Caddy

The code for the **[Docker Series on YouTube](https://bit.ly/docker-series)**. This workspace
repo holds the shared pieces — `infra/`, the `Tiltfile`, Caddy — and a `main/` folder holding a
clone of each app repo.

Every video that changes the code has a **start and an end tag**, and the same tag exists in this
repo *and* in every app repo. Clone once:

```sh
git clone https://github.com/rahulpnath/tilt-series
cd tilt-series
```

then put everything on the tag for the video you're watching — the start tag to follow along, the
end tag for the finished result. `bootstrap.sh` checks this repo out at the tag and clones each app
repo at the same tag into `main/`; repos the series hasn't introduced yet are skipped. The
README at each tag says what to run from there.

## The videos

1. **[Docker 101 — Everything You Need to Get Started](https://www.youtube.com/watch?v=22bkOL7fhiY)**
   The concepts — images, containers, how Docker works. No code to pull.
2. **[Your First Dockerfile — Containerize a .NET API](https://youtu.be/qdp8Pekjeu8)**
   ```sh
   ./bootstrap.sh v1-start    # follow along
   ./bootstrap.sh v1-end      # finished
   ```
3. **[Hot Reload in a Docker Container — A Dev Dockerfile for .NET](https://youtu.be/qWDga_UOqFg)**
   ```sh
   ./bootstrap.sh v1.2-start
   ./bootstrap.sh v1.2-end
   ```
4. **[Your First Docker Compose File — Run a Multi-Service .NET App](https://youtu.be/5ctaQBGGcyQ)**
   ```sh
   ./bootstrap.sh v2-start
   ./bootstrap.sh v2-end
   ```
5. **[Docker Networking Explained — Connect Apps Across Compose Projects](https://youtu.be/P1rlVywY7Ic)**
   ```sh
   ./bootstrap.sh v3-start
   ./bootstrap.sh v3-end
   ```
6. **[Git Worktrees Explained — Stop Stashing, Start Working in Parallel](https://youtu.be/AocVvPxPQeY)**
   No tag — it works on any app repo as it is on `main`. The video uses Orders:
   ```sh
   git clone https://github.com/rahulpnath/tilt-series-orders Shop.Orders
   ```

More videos are on the way; their tags appear here as each one is published.

---

## You are at `v6-end`

Any folder of the workspace now runs as **its own full copy of the app**, side by side with the
others: its own containers, database, message broker and network, its own group in Docker
Desktop, and its own addresses. `main/` is one such folder; a feature folder like
`feature-pricing/` is another.

### Run `main`

```sh
for d in infra main/Shop.Catalog main/Shop.Orders; do echo 'SA_PASSWORD=P@ssw0rd!Demo1' > $d/.env; done

docker compose -f caddy/compose.yaml up -d    # once — Docker restarts it with the machine
tilt up
```

Caddy runs on its own, outside Tilt, because every folder goes through it. Start it once;
`restart: unless-stopped` brings it back whenever Docker starts, and no `tilt down` stops it.

Every name carries the folder's name as a suffix. For `main`:

- https://storefront-main.localhost — the Storefront · https://admin-main.localhost — Admin
- https://catalog-main.localhost/products · https://orders-main.localhost/orders — the APIs
- Docker Desktop: `shop-main` (eight containers) and `shop-caddy`

### Run a feature folder beside it

A feature folder holds worktrees of only the repos the feature changes; the rest run from
`main/`. The series' example is a `feature-pricing` branch in Orders and the Storefront:

```sh
git -C main/Shop.Orders worktree add ../../feature-pricing/Shop.Orders feature-pricing
git -C main/Shop.Storefront worktree add ../../feature-pricing/Shop.Storefront feature-pricing
cp main/Shop.Orders/.env feature-pricing/Shop.Orders/

tilt up feature-pricing --port 10351
```

- `feature-pricing` after `tilt up` is the folder to run; with nothing after it, it's `main`.
- `--port` because each Tilt needs its own UI port, and `main`'s already has 10350.
- **Each feature folder needs its own `.env`** in every repo that has one — git worktrees don't
  bring ignored files with them. [Worktrunk](https://worktrunk.dev/step/#wt-step-copy-ignored)
  can copy them for you.

The feature is then at https://storefront-feature-pricing.localhost (and `admin-`, `catalog-`,
`orders-feature-pricing.localhost`), in a `shop-feature-pricing` group, with an empty database of
its own. Catalog and Admin come from `main/`, unchanged. `tilt down feature-pricing` removes only
that copy.

### Trust Caddy's root certificate (once)

Caddy signs every address with a certificate authority of its own. Trust its root once, and every
address it serves — today's and any future folder's — is trusted.

```sh
cd caddy
docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt ./root.crt
```

- **Windows** — double-click `root.crt` → *Install Certificate* → *Current User* → *Place all
  certificates in the following store* → *Trusted Root Certification Authorities*, or
  `certutil -user -addstore Root root.crt`. Chrome and Edge read this store. From WSL2 the file
  is at `\\wsl.localhost\<distro>\home\…\caddy\root.crt`.
- **macOS** — `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain root.crt`
- **Linux** — `sudo cp root.crt /usr/local/share/ca-certificates/caddy-local.crt && sudo update-ca-certificates`;
  Chrome on Linux keeps its own store: `certutil -d sql:$HOME/.pki/nssdb -A -t C -n caddy-local -i root.crt`
- **Firefox** keeps its own store on every OS — set `security.enterprise_roots.enabled` to `true`
  in `about:config` and it uses the system's.

The root lives in the `shop-caddy_caddy-data` volume; remove the volume and Caddy makes a new
one, which you trust again. Skip trusting it and the Storefront's `fetch` calls to the APIs fail
silently — there is no click-through for a `fetch`.

### What is here

```
tilt-series/
├── Tiltfile             # reads the folder from `tilt up`, picks each repo's folder, one project per folder
├── compose.yaml         # project `shop`: includes every repo's compose file and infra's
├── bootstrap.sh
├── infra/
│   ├── compose.yaml     # sqlserver + rabbitmq, one set per folder
│   └── .env             # you create this; gitignored
├── caddy/
│   ├── compose.yaml     # shop-caddy: run once on its own, owns `shopnet`
│   ├── Caddyfile        # one *.localhost block: <app>-<folder>.localhost → that folder's app
│   └── root.crt         # exported by you; gitignored
├── main/
│   ├── Shop.Catalog/    ← github.com/rahulpnath/tilt-series-catalog
│   ├── Shop.Orders/     ← github.com/rahulpnath/tilt-series-orders
│   ├── Shop.Storefront/ ← github.com/rahulpnath/tilt-series-storefront
│   └── Shop.Admin/      ← github.com/rahulpnath/tilt-series-admin
└── feature-pricing/     # optional: worktrees of the repos a feature changes
```

**Don't put a `.env` next to the workspace `compose.yaml`.** Compose would read it for the whole
project, and its values would win over each repo's own `.env`.

### What changed since `v5-end`

**Docker Compose Include** (`v5.2-end`) — the whole app as one compose project:

- **`compose.yaml` in the workspace** `include`s every repo's compose file and infra's. Each
  included file keeps its own folder for paths (`context: .`, `./src`) and its own `.env`.
- **Unique service names** — `catalog-api`, `orders-api`, `storefront-web`, … — because one
  project can't have two services called `api`. The Tiltfiles' `new_name=` went with them.
- **One `docker_compose()` call** in the root Tiltfile loads that file; the repos' Tiltfiles keep
  only their `dc_resource` lines.
- **Caddy owns `shopnet`** now, not infra: infra is inside the project, and a project can't
  create a network its own services declare `external`. The workers left `shopnet` — they find
  infra on the project's own network.

**Parallel Worktree Environments** (`v6-end`) — one copy of the app per folder:

- **The folder's name is a suffix on every name**: the address (`storefront-main.localhost`), the
  name on `shopnet` (`storefront-web-${FOLDER:-main}`) and the compose project (`shop-main`).
- **The root Tiltfile** reads the folder with `config.define_string('folder', args=True)`, passes
  it on as `FOLDER` with `os.putenv`, and names the project `'shop-' + folder`. `repo_dir()`
  picks each repo's folder — the feature's if it has the repo, else `main/` — and sets
  `CATALOG_DIR`, `ORDERS_DIR`, … for the include paths and the repos' own Tiltfiles.
- **The Caddyfile** is one `*.localhost` block. Each rule reads the folder out of the address with
  a regex and forwards to `<app>-<folder>`. `tls internal { on_demand }` makes a certificate per
  address on first visit, because browsers don't accept a single `*.localhost` wildcard.
  Anything unmatched gets `Nothing running at …`.
- **Caddy left Tilt** — `restart: unless-stopped`, started once, shared by every folder.
- **Infra's ports are gone** (1433, 15672) — a second folder would want the same ones.

`tilt down` (or `tilt down <folder>`) stops that folder's copy without `-v`, so its database stays.

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/) and
[Tilt](https://docs.tilt.dev/install.html).
