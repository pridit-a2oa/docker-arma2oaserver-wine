FROM ubuntu:18.04

ARG RCON_PASSWORD=secret

VOLUME arma2oaserver

# Download necessary packages
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install --install-recommends -y \
		ca-certificates \
		cabextract \
		net-tools \
		novnc \
		procps \
		supervisor \
		wget \
		wine-stable \
		wine32 \
		wine64 \
		x11vnc \
		xauth \
		xvfb \
		unzip && \
	apt-get remove --purge -y && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm /var/lib/apt/lists/* -r && \
	ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html

# Download Winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks && \
	chmod +x /usr/bin/winetricks

# Setup Wine environment
RUN winetricks sound=disabled && \
	winetricks windowmanagermanaged=n

# Install dependencies
RUN W_OPT_UNATTENDED=1 xvfb-run winetricks \
		arial \
		dotnet462 \
		vcrun2013 \
		vcrun2017 \
	2>/dev/null && \
	rm -rf  ~/.cache ~/.config ~/.local /tmp/*

# Copy supervisord.conf
COPY supervisord.conf /torch-server/supervisord.conf

# Start supervisord
CMD ["supervisord", "-c", "/torch-server/supervisord.conf"]