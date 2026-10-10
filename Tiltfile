config.define_string('folder', args=True)
folder = config.parse().get('folder', 'main')
os.putenv('FOLDER', folder)

def repo_dir(repo):
    if os.path.exists(folder + '/' + repo):
        return folder + '/' + repo
    return 'main/' + repo

repos = {
    'Shop.Catalog': 'CATALOG_DIR',
    'Shop.Orders': 'ORDERS_DIR',
    'Shop.Storefront': 'STOREFRONT_DIR',
    'Shop.Admin': 'ADMIN_DIR',
}
for repo, var in repos.items():
    os.putenv(var, repo_dir(repo))

docker_compose('compose.yaml', project_name='shop-' + folder)

for repo in repos:
    include(repo_dir(repo) + '/Tiltfile')

dc_resource('sqlserver', labels=['infra'])
dc_resource('rabbitmq', labels=['infra'])

for app in ['catalog-api', 'catalog-worker', 'orders-api', 'orders-worker',
            'storefront-web', 'admin-web']:
    dc_resource(app, resource_deps=['sqlserver', 'rabbitmq'])
