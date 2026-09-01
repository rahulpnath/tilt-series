# Where a repo lives: a checkout beside this workspace wins over the one in
# main/. That preference is what lets a worktree run its own copy in Video 6.
def repo_dir(name):
    for candidate in [name, 'main/' + name]:
        if os.path.exists(candidate + '/Tiltfile'):
            return candidate
    return ''
