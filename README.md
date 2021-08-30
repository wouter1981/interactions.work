This repo is the master repo containing all services as submodules

Do once
```
git config submodule.recurse=1
git config push.recursesubmodules=on-demand
```

Some helpful commands:
```
git status
git submodule status
git submodule update --remote (update reference to latest on remote branch)

git pull (recurses submodules because of above config)
```

You can work with the main solution and start projects in VS Code from this, but we advise to use git commands in the submodule when updating a service and publishing each service individually. See README's in the sub projects for more info.