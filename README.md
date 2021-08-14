This repository contains the files required to build an image with the dependencies to operate an **Arma 2: Operation Arrowhead** server under Wine.

**Arma 2** data files are also included so missions can make use of the assets.

## Requirements
* [Steam](https://store.steampowered.com/about/) account with an active subscription to both Arma 2 & Arma 2: Operation Arrowhead.

## Setup
```bash
git clone https://github.com/pridit/docker-arma2oaserver.git
```

Make a copy of the three `.example` files, removing this suffix, and modify server configuration with your own preferences.

```bash
docker build -t arma2oaserver .
```

Since `RCON_PASSWORD` is set on build (to populate a configuration file) should this need to be changed in the future you must modify the file ending in `.cfg` within the directory `/arma2oaserver/expansion/battleye` inside the container. As the file is automatically renamed it is not feasible to mount.

Without the argument being specified at build the value will default to `secret`.

## Data
This image does not contain any data files, given that they can not be downloaded without an active subscription to the packages on Steam. For this purpose, I would recommend leveraging the official [SteamCMD](https://hub.docker.com/r/steamcmd/steamcmd) Docker image and having that content ready (or merged if sharing assets) before building and using this image.

```bash
docker run -it \
    -v arma2oaserver:/root/.steam \
    steamcmd/steamcmd:latest \
    +@sSteamCmdForcePlatformType windows \
    +login USERNAME PASSWORD \
    +app_update 33930 \
    +app_update 33900 \
    +quit
```

>Arma 2 is under two different package App IDs. **33910** (RoW) or **33900** (bought on Steam). Depending on how your Steam account owns Arma 2 this may need to change. Due to quirks, the command may need to be executed multiple times (another reason the downloads aren't included as part of this repo).

Directories you are going to want to merge from `Arma 2` into `Arma 2 Operation Arrowhead` to support shared content are as follows:

- AddOns
- Dta

Now that we have a built image and the game data we can start up the container as follows:

```bash
docker create \
    --name=arma2oaserver \
    --net=host \
    --restart unless-stopped \
    -v arma2oaserver:/arma2oa \
    -v $PWD/keys:/arma2oa/Arma\ 2\ Operation\ Arrowhead/Expansion/Keys \
    -v $PWD/mpmissions:/arma2oa/Arma\ 2\ Operation\ Arrowhead/MPMissions \
    -v $PWD/params:/arma2oa/Arma\ 2\ Operation\ Arrowhead/params \
    -v $PWD/basic.cfg:/arma2oa/Arma\ 2\ Operation\ Arrowhead/basic.cfg \
    -v $PWD/server.cfg:/arma2oa/Arma\ 2\ Operation\ Arrowhead/server.cfg \
    arma2oaserver
```

## Attribution
With thanks to [adamharley/torch-docker](https://github.com/adamharley/torch-docker) from which this repository is loosely based from.
