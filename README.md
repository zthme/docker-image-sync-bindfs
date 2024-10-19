sync-bindfs
===========

Set up mount from source to target via `bindfs` to remap uid.

This utility is intended for use in Linux environments until `X-mount.idmap` support is more widespread.
In particular, as WSL2 does not yet support rootless Docker or other user remap techniques, this workaround provides
for this need.


Requirements
------------

The `bindfs` usage requires the following to remap uid over `/dev/fuse`:

- `SYS_ADMIN` capability
- `/dev/fuse` device

As used in `docker run`:

```
docker run --cap-add SYS_ADMIN --device /dev/fuse 
```

As configured in `docker-compose.yml`:

```yaml
services:
    sync:
        cap_add:
            - SYS_ADMIN
        devices:
            - /dev/fuse
```


Configuration
-------------

Three directories inside the container function as stages:

1. `/sync/host` - Host directory, as host user
2. `/sync/bind` - Bind directory, as app user mapped from host user 
3. `/sync/app` - App directory, as expected app user

Available environment variables:

- `HOST_UID` - Host directory user id (default: 1000)
- `HOST_GID` - Host directory group id (default: 1000)
- `APP_UID` - App directory user id (default: 0)
- `APP_GID` - App directory group id (default: 0)
- `UNISON_OPTIONS` - Optional `unison` arguments, on top of the internally mandatory `-batch -owner -group -times`
- `UNISON_WATCH` - Whether to run as continuous sync (default: 0), can be run as service if 1


### Example

```yaml
services:
    # Main application
    app:
        volumes:
            - app_volume:/app
        depends_on:
            - appsync

    # Sync service
    appsync:
        image: zthme/sync-bindfs
        volumes:
            # Pass host directory into source directory.
            - .:/sync-host
            # Mount volume into target directory.
            - app_volume:/sync-app
        environment:
            # Set Unison options to fine tune sync.
            UNISON_OPTIONS: -prefer /sync-host -ignore='BelowPath uploads'
            UNISON_WATCH: 1
        # Add required privileges.
        cap_add:
            - SYS_ADMIN
        devices:
            - /dev/fuse

volumes:
  app_volume: {}
```
