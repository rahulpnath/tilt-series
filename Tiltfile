include('main/Shop.Catalog/Tiltfile')
include('main/Shop.Orders/Tiltfile')
include('main/Shop.Storefront/Tiltfile')
include('main/Shop.Admin/Tiltfile')

docker_compose('infra/compose.yaml', project_name='shop-infra', wait=True)
dc_resource('sqlserver', labels=['infra'])
dc_resource('rabbitmq', labels=['infra'])

# The .NET apps join infra's network, so infra has to be up first.
for app in ['catalog-api', 'catalog-worker', 'orders-api', 'orders-worker']:
    dc_resource(app, resource_deps=['sqlserver', 'rabbitmq'])
