# Arma 2: Operation Arrowhead Server (Docker + Wine)

This repository contains the files required to build an image with the dependencies to operate an **Arma 2: Operation Arrowhead** server using Docker and Wine.

## Requirements
* [Steam](https://store.steampowered.com/about/) account with an active subscription to the game (optionally Arma 2 as well, if you use the content).

## Setup
```bash
git clone https://github.com/pridit/docker-arma2oaserver-wine.git
```

Make a copy of the three `.example` files, removing this suffix, and modify server configuration with your own preferences.

Build the image so we can use it later:

```bash
docker build -t arma2oaserver .
```

### Download
This image does not contain any data files, given that they can not be downloaded without an active subscription to the packages on Steam.

For this purpose, I would recommend leveraging the official [SteamCMD](https://hub.docker.com/r/steamcmd/steamcmd) Docker image and having that content ready (or merged if sharing assets) before moving further.

```bash
docker run -it \
    -v arma2oaserver:/root/Steam \
    steamcmd/steamcmd:latest \
    +@sSteamCmdForcePlatformType windows \
    +login USERNAME PASSWORD
```

Once authenticated you will be presented with a prompt inside the container.

To download Arma 2: Operation Arrowhead content:

```bash
app_update 33930
```

To download Arma 2 content:

```bash
app_update 33900
```

>Arma 2 is under two different package App IDs. **33910** (RoW) and **33900** (bought on Steam). Depending on how your Steam account owns Arma 2 this may need to change.

>Due to quirks with either the package or SteamCMD, the process may fail and would need to be executed repeatedly.

Once this has downloaded you can exit the prompt with `quit` and move on.

### Container

Now that we have a built image and the game data we can start the container as follows:

```bash
docker run -d \
    --name=arma2oaserver \
    --net=host \
    --restart unless-stopped \
    -v arma2oa:/arma2oa \
    -v $PWD/keys:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/Expansion/Keys \
    -v $PWD/mpmissions:/arma2oa/steamapps/common/Arma\ 2\ Operation\ Arrowhead/MPMissions \
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

Create a `beserver.cfg` file to ensure RCON capability. Replace **PASSWORD** with one of your choosing as per the below:

```bash
echo "RConPassword PASSWORD" > $PWD/profiles/BattlEye/beserver.cfg
```

>This file will be automatically renamed when it is used to signify that it is active.

## VNC
As the executable window outputs the RCON password every time it starts up, it is pretty important that this is secured.

You can do this by accessing the container and running:

```bash
x11vnc -storepasswd
```

VNC will not start up unless this has been set.

## Attribution
With thanks to [adamharley/torch-docker](https://github.com/adamharley/torch-docker) from which this repository is loosely based from.
