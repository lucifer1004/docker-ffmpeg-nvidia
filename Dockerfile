FROM nvidia/cuda:10.0-devel
WORKDIR /tmp

RUN apt-get update && apt-get install -y git build-essential yasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev frei0r-plugins-dev libgnutls28-dev libass-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenjp2-7-dev libopus-dev librtmp-dev libsoxr-dev libspeex-dev libtheora-dev libvo-amrwbenc-dev libvorbis-dev libvpx-dev libwebp-dev libx264-dev libx265-dev libxvidcore-dev chromium-browser xvfb libpulse-dev libxcb1-dev

COPY build-ffmpeg.sh build-ffmpeg.sh
RUN chmod +x build-ffmpeg.sh

RUN ./build-ffmpeg.sh

ENV UNAME zukdoor

RUN apt-get update && apt-get install -y sudo pulseaudio

RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

USER $UNAME
ENV HOME /home/zukdoor
WORKDIR $HOME
COPY entrypoint.sh .
COPY .asoundrc .
COPY yahei.ttf /usr/share/fonts/TTF

ENTRYPOINT [ "sh", "-c", "./entrypoint.sh" ]