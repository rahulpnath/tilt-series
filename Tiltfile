include('main/Shop.Catalog/Tiltfile')
include('main/Shop.Orders/Tiltfile')
include('main/Shop.Storefront/Tiltfile')
include('main/Shop.Admin/Tiltfile')

docker_compose('infra/compose.yaml', project_name='shop-infra', wait=True)
dc_resource('sqlserver', labels=['infra'])
dc_resource('rabbitmq', labels=['infra'])

docker_compose('caddy/compose.yaml', project_name='shop-caddy')
dc_resource('caddy', labels=['caddy'])

# Everything on shopnet needs infra up first — it owns the network.
for app in ['catalog-api', 'catalog-worker', 'orders-api', 'orders-worker', 'caddy']:
    dc_resource(app, resource_deps=['sqlserver', 'rabbitmq'])
