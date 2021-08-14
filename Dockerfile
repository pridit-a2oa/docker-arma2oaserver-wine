FROM debian:stable-slim

ARG RCON_PASSWORD=secret

VOLUME arma2oaserver

# Download necessary packages
RUN dpkg --add-architecture i386 && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
		ca-certificates \
		cabextract \
		net-tools \
		novnc \
		procps \
		supervisor \
		wget \
		wine \
		wine32 \
		wine64 \
		x11vnc \
		xauth \
		xvfb \
		unzip && \
	apt-get clean && rm -rf /var/lib/apt/lists/* && \
	ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html

# Download Winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks && \
	chmod +x /usr/bin/winetricks

# Setup Wine environment
RUN winetricks sound=disabled && \
	winetricks windowmanagermanaged=n

# Install dependencies
RUN W_OPT_UNATTENDED=1 xvfb-run winetricks \
		dotnet462 \
		vcrun2013 \
		vcrun2017 \
	2>/dev/null && \
	rm -rf  ~/.cache ~/.config ~/.local /tmp/*

# Copy supervisord.conf
COPY supervisord.conf /supervisord.conf

# Start supervisord
CMD ["supervisord", "-c", "/supervisord.conf"]