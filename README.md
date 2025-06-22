# Arma 2: Operation Arrowhead Server

This repository contains the files required to build an image with the dependencies to operate an **Arma 2: Operation Arrowhead** server, using [Docker](https://www.docker.com/) and [Wine](https://www.winehq.org/) to achieve this.

> [!NOTE]
> These instructions assume basic understanding of `git` and `docker` CLI use, that you have a Linux environment capable of executing these commands, and a disk with at least **10 GB** of available space.

## Requirements

- [Steam](https://store.steampowered.com/about/) account owning the game

## Setup

```bash
git clone https://github.com/pridit/docker-arma2oaserver-wine.git
```

Make a copy of the three `.example` files, removing this suffix, and modify server configuration with your own preferences.

Start by building the image so we can use it later:

```bash
docker build -t arma2oaserver .
```

> [!NOTE]
> It is normal for the image build process to take some time, potentially up to 15 minutes.

### Game Content

This image does not contain any data files, given that this is licensed content that cannot be downloaded without an active subscription to the packages on Steam. As a result, we'll be mounting a Docker volume at runtime.

For this purpose, I would recommend leveraging the official [SteamCMD](https://hub.docker.com/r/steamcmd/steamcmd) Docker image and having that content ready/[merged](#shared-content) (if using assets from Arma 2).

> [!IMPORTANT]
> This data needs to exist before starting the container, however you choose to do that. If you already have game data in a volume, this section can be skipped.

```bash
docker volume create arma2oa
```

```bash
docker run -it \
    -v arma2oa:/root/.local/share/Steam \
    steamcmd/steamcmd:latest \
    +@sSteamCmdForcePlatformType windows \
    +login USERNAME PASSWORD
```

Once authenticated you will be presented with a prompt inside the container.

> [!WARNING]
> Due to quirks with either the package or SteamCMD, the download process may erroneously fail and in such cases the following commands must be executed repeatedly to complete.

To download Arma 2: Operation Arrowhead content:

```bash
app_update 33930 validate
```

To download Arma 2 content:

```bash
app_update 33900 validate
```

> [!NOTE]
> Arma 2 exists under two different package App IDs. [33910](https://steamdb.info/app/33910/) (RoW) and [33900](https://steamdb.info/app/33900/) (bought directly on Steam). Depending on how your Steam account owns Arma 2 the command line may need to change.

Once this has downloaded you can exit the prompt with `quit` and move on.

### Container

Now that we have a built image and a volume with the game data we can start the container as follows:

```bash
docker run -d \
    --name=arma2oaserver \
    --net=host \
    --restart unless-stopped \
    -v arma2oa:/arma2oa \
    -v $PWD/keys:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/Expansion/Keys \
    -v $PWD/mpmissions:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/MPMissions \
    -v $PWD/logs:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/logs \
    -v $PWD/params:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/params \
    -v $PWD/profiles:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/profiles \
    -v $PWD/basic.cfg:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/basic.cfg \
    -v $PWD/server.cfg:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/server.cfg \
    arma2oaserver
```

## Shared Content

To support shared content directories you are going to want to merge from `Arma 2` into `Arma 2 Operation Arrowhead` are the following:

- AddOns
- Dta

## RCON

To enable RCON we need to create a new file called `beserver.cfg` as per the below:

```bash
echo "RConPassword CHANGEME" > $PWD/profiles/BattlEye/beserver.cfg
```

> [!NOTE]
> This file will be automatically renamed.

## Attribution

With thanks to [adamharley/torch-docker](https://github.com/adamharley/torch-docker), from which this repository is loosely based from.
