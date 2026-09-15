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

## You are at `v3-end`

Three projects, shared infrastructure, and now the call between the apps works. **`infra/`**
holds SQL Server and RabbitMQ in a compose project of their own (`shop-infra`), on a network
named **`shopnet`**. `main/Shop.Catalog` and `main/Shop.Orders` join that network; on it,
Catalog's API answers to the alias **`catalog-api`** and Orders' to **`orders-api`**. Both
APIs carry a dev-only CORS policy so `main/Shop.Storefront` can call them from the browser.

Three `.env` files (not committed), then infra first:

```sh
for d in infra main/Shop.Catalog main/Shop.Orders; do echo 'SA_PASSWORD=P@ssw0rd!Demo1' > $d/.env; done

(cd infra                && docker compose up -d --wait)
(cd main/Shop.Catalog    && docker compose up -d)
(cd main/Shop.Orders     && docker compose up -d)
(cd main/Shop.Storefront && docker compose up -d)
```

Infra first — the app projects declare `shopnet` as `external`, so their `up` stops if it
isn't there yet.

```sh
curl -X POST http://localhost:5101/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Pour Over Kettle","price":119.00}'

curl -X POST http://localhost:5102/orders \
  -H 'Content-Type: application/json' \
  -d '{"productId":1,"quantity":2}'
# {"id":1,"productId":1,"productName":"Pour Over Kettle","unitPrice":119.00,"quantity":2}
```

Then http://localhost:5173 — the Storefront lists the products and places orders.

```
tilt-series/
├── bootstrap.sh
├── infra/
│   ├── compose.yaml             # shop-infra: sqlserver + rabbitmq, network `shopnet`
│   └── .env                     # you create this; gitignored
└── main/
    ├── Shop.Catalog/            ← github.com/rahulpnath/tilt-series-catalog     :5101
    │   ├── compose.yaml         # api + worker on `default` and `shopnet`; alias `catalog-api`
    │   └── .env
    ├── Shop.Orders/             ← github.com/rahulpnath/tilt-series-orders      :5102
    │   ├── compose.yaml         # same shape; alias `orders-api`; calls http://catalog-api:5101
    │   └── .env
    └── Shop.Storefront/         ← github.com/rahulpnath/tilt-series-storefront  :5173
        └── compose.yaml         # web; calls both APIs from the browser
```

`main/Shop.Admin` is **skipped at this tag** — video 4 introduces it.

**Prerequisites at this tag:** [Docker](https://docs.docker.com/get-started/get-docker/)
only. The .NET SDK, Node, SQL Server and RabbitMQ all run in containers.

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
