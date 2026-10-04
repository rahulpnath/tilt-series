folder = 'main'
os.putenv('FOLDER', folder)

docker_compose('compose.yaml', project_name='shop-' + folder)

include('main/Shop.Catalog/Tiltfile')
include('main/Shop.Orders/Tiltfile')
include('main/Shop.Storefront/Tiltfile')
include('main/Shop.Admin/Tiltfile')

dc_resource('sqlserver', labels=['infra'])
dc_resource('rabbitmq', labels=['infra'])

for app in ['catalog-api', 'catalog-worker', 'orders-api', 'orders-worker',
            'storefront-web', 'admin-web']:
    dc_resource(app, resource_deps=['sqlserver', 'rabbitmq'])
