# One control tower over the four repos' own Tiltfiles. Each repo keeps its own
# compose project, so nothing in any compose.yaml changed to make this work.
load('./tilt/shared.Tiltfile', 'repo_dir')

for name in ['Shop.Catalog', 'Shop.Orders', 'Shop.Storefront', 'Shop.Admin']:
    d = repo_dir(name)
    if d:
        include(d + '/Tiltfile')
    else:
        print('skip  ' + name + ' — not checked out')
