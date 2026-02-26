FROM debian:bookworm-slim

# Install seafile client using AppImage (Official recommended way)
RUN apt-get update && \
    apt-get install -y curl python3.11-venv libfuse2 kmod && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://sos-ch-dk-2.exo.io/seafile-downloads/Seafile-x86_64-9.0.16.AppImage -o /usr/local/bin/seafile-appimage && \
    chmod +x /usr/local/bin/seafile-appimage && \
    /usr/local/bin/seafile-appimage --appimage-extract && \
    mv squashfs-root /opt/seafile-client && \
    ln -s /opt/seafile-client/usr/bin/seaf-cli /usr/local/bin/seaf-cli && \
    ln -s /opt/seafile-client/usr/bin/seafile /usr/local/bin/seafile

# Use virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv --system-site-packages $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install app requirements
WORKDIR /dsc
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY dsc ./dsc/
COPY start.py ./start.py

# Create seafile user and init seafile client
RUN chmod +x /dsc/start.py && \
    useradd -U -d /dsc -s /bin/bash seafile && \
    usermod -G users seafile && \
    mkdir -p /dsc/seafile-data && \
    chown seafile:seafile -R /dsc

VOLUME /dsc/seafile-data
CMD ["./start.py"]
