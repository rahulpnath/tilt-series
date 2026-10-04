docker_compose('compose.yaml', project_name='shop')

include('main/Shop.Catalog/Tiltfile')
include('main/Shop.Orders/Tiltfile')
include('main/Shop.Storefront/Tiltfile')
include('main/Shop.Admin/Tiltfile')

dc_resource('sqlserver', labels=['infra'])
dc_resource('rabbitmq', labels=['infra'])

docker_compose('caddy/compose.yaml', project_name='shop-caddy')
dc_resource('caddy', labels=['caddy'])

# Caddy owns shopnet, so the apps wait for it as well as infra.
for app in ['catalog-api', 'catalog-worker', 'orders-api', 'orders-worker',
            'storefront-web', 'admin-web']:
    dc_resource(app, resource_deps=['sqlserver', 'rabbitmq', 'caddy'])
