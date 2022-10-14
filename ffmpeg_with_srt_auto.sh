# combination of steps from 
# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu 
# and 
# https://seanthegeek.net/455/how-to-compile-and-install-ffmpeg-4-0-on-debian-ubuntu/


response=
libpulse_reponse="yes"
libaom_reponse="yes"


echo -n "installing dependencies as mentioned in https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu"
sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev

echo -n "installing dependencies as mentioned in https://seanthegeek.net/455/how-to-compile-and-install-ffmpeg-4-0-on-debian-ubuntu/"
sudo apt-get -y install build-essential autoconf automake cmake libtool git \
checkinstall nasm yasm libfreetype6-dev libsdl2-dev libtool \
libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev libchromaprint-dev \
frei0r-plugins-dev gnutls-dev ladspa-sdk libcaca-dev libcdio-paranoia-dev \
libcodec2-dev libfontconfig1-dev libfribidi-dev libgme-dev \
libgsm1-dev libjack-dev libmodplug-dev libmp3lame-dev libopencore-amrnb-dev \
libopencore-amrwb-dev libopenjp2-7-dev libopenmpt-dev libopus-dev \
libpulse-dev librsvg2-dev librubberband-dev librtmp-dev libshine-dev \
libsmbclient-dev libsnappy-dev libsoxr-dev libspeex-dev libssh-dev \
libtesseract-dev libtheora-dev libtwolame-dev libv4l-dev libvo-amrwbenc-dev \
libvorbis-dev libvpx-dev libwavpack-dev libwebp-dev libx264-dev libx265-dev \
libxvidcore-dev libxml2-dev libzmq3-dev libzvbi-dev liblilv-dev libmysofa-dev \
libopenal-dev opencl-dev

echo -n "create dirs - ~/ffmpeg_sources ~/bin ~/ffmpeg_build/lib/pkgconfig"
mkdir -p ~/ffmpeg_sources ~/bin ~/ffmpeg_build/lib/pkgconfig

echo -n "copy existing pkgconfig to ffmpeg_build"
cp -rf /usr/lib/x86_64-linux-gnu/pkgconfig $HOME/ffmpeg_build/lib/pkgconfig

# install latest nasm assembler as its used during compilation by certain libs 
echo -n "compile / install - nasm"
cd ~/ffmpeg_sources && \
wget -O nasm-2.14.tar.bz2 https://www.nasm.us/pub/nasm/releasebuilds/2.14/nasm-2.14.tar.bz2 && \
tar xjvf nasm-2.14.tar.bz2 && \
cd nasm-2.14 && \
./autogen.sh && \
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
make && \
make install

# install latest yasm assembler as its used during compilation by certain libs 
echo -n "compile / install - yasm"
cd ~/ffmpeg_sources && \
wget -O yasm-1.3.0.tar.gz https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && \
tar xzvf yasm-1.3.0.tar.gz && \
cd yasm-1.3.0 && \
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
make && \
make install

# install latest x264
echo -n "compile / install - x264"
cd ~/ffmpeg_sources && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
cd x264 && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic && \
PATH="$HOME/bin:$PATH" make && \
make install

# install latest x265
echo -n "compile / install - x265"
sudo apt-get install mercurial libnuma-dev -y && \
cd ~/ffmpeg_sources && \
git -C x265_git pull 2> /dev/null || git clone --depth 1 --branch 3.5 https://bitbucket.org/multicoreware/x265_git && \
cd x265_git/build/linux && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off ../../source && \
PATH="$HOME/bin:$PATH" make && \
make install

# install latest fdk-aac
echo -n "compile / install - fdk-aac"
# OPTIONAL - THIS STEP CAN BE SKIPPED
cd ~/ffmpeg_sources && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
make && \
make install

# install libpulse
# OPTIONAL - THIS STEP CAN BE SKIPPED
if [ "$libpulse_reponse" = "yes" ]; then
	printf "compile / install - libpulse"
	sudo apt-get install libsndfile1-dev autopoint libtdb-dev doxygen -y && \
	cd ~/ffmpeg_sources && \
	wget -O pulseaudio-16.1.tar.xz https://freedesktop.org/software/pulseaudio/releases/pulseaudio-16.1.tar.xz && \
	tar xJvf pulseaudio-16.1.tar.xz && \
	cd pulseaudio-16.1 && \
	PATH="$HOME/bin:$PATH" meson --prefix="$HOME/ffmpeg_build" -Dman=false -Dtests=false -Ddaemon=false -Ddoxygen=false build && \
	ninja -C build install
else
	printf "\n\nlibpulse will be skipped\n\n"
fi

# install latest libaom
# OPTIONAL - THIS STEP CAN BE SKIPPED
if [ "$libaom_reponse" = "yes" ]; then
	printf "compile / install - libaom"
	cd ~/ffmpeg_sources && \
	git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
	mkdir aom_build && \
	cd aom_build && \
	PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on -DENABLE_DOCS=off -DENABLE_TESTS=off ../aom && \
	PATH="$HOME/bin:$PATH" make && \
	make install
else
	printf "\n\nlibaom will be skipped\n\n"
fi

# echo -n "compile / install - libaom"
# mkdir -p ~/ffmpegtemp/aom
# cd ~/ffmpegtemp/aom
# git clone https://aomedia.googlesource.com/aom
# cmake aom/
# make
# sudo checkinstall -y --deldoc=yes
# cd

# build libsrt
sudo apt-get install libssl-dev
cd ~/ffmpeg_sources
git -C srt pull 2> /dev/null || git clone --depth 1 https://github.com/Haivision/srt.git
mkdir srt/build
cd srt/build
cmake -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_C_DEPS=ON -DENABLE_SHARED=OFF -DENABLE_STATIC=ON ..
make
make install

# build libvpx
cd ~/ffmpeg_sources && \
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
cd libvpx && \
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
PATH="$HOME/bin:$PATH" make && \
make install

# build libopus - for audio with vpx-vp9
cd ~/ffmpeg_sources && \
git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
cd opus && \
./autogen.sh && \
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
make && \
make install

# install latest ffmpeg
echo -n "compile / install - ffmpeg"
cd ~/ffmpeg_sources && \
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig:$HOME/ffmpeg_build/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm -lz" \
  --extra-ldexeflags="-static" \
  --bindir="$HOME/bin" \
  --enable-ffplay \
  --enable-gpl \
  --enable-libaom \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree \
  --enable-libsrt \
  --enable-libvpx \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libpulse && \
PATH="$HOME/bin:$PATH" make && \
make install && \
hash -r
printf "\n========\n| DONE |\n========\n"


# ffmpeg version 4.0.3-1~18.04.york0 Copyright (c) 2000-2018 the FFmpeg developers
#   built with gcc 7 (Ubuntu 7.3.0-27ubuntu1~18.04)
#   configuration: --prefix=/usr --extra-version='1~18.04.york0' --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --arch=amd64 --enable-gpl --disable-stripping --enable-avresample --disable-filter=resample --enable-avisynth --enable-gnutls --enable-ladspa --enable-libaom --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libcodec2 --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libjack --enable-libmp3lame --enable-libmysofa --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librsvg --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvidstab --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxml2 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-lv2 --enable-omx --enable-openal --enable-opengl --enable-sdl2 --enable-libdc1394 --enable-libdrm --enable-libiec61883 --enable-chromaprint --enable-frei0r --enable-libopencv --enable-libx264 --enable-shared
#   libavutil      56. 14.100 / 56. 14.100
#   libavcodec     58. 18.100 / 58. 18.100
#   libavformat    58. 12.100 / 58. 12.100
#   libavdevice    58.  3.100 / 58.  3.100
#   libavfilter     7. 16.100 /  7. 16.100
#   libavresample   4.  0.  0 /  4.  0.  0
#   libswscale      5.  1.100 /  5.  1.100
#   libswresample   3.  1.100 /  3.  1.100
#   libpostproc    55.  1.100 / 55.  1.100


# ffmpeg version N-92806-g70c86deb8e Copyright (c) 2000-2018 the FFmpeg developers
#   built with gcc 7 (Ubuntu 7.3.0-27ubuntu1~18.04)
#   configuration: --prefix=/home/ubuntu/ffmpeg_build --pkg-config-flags=--static --extra-cflags=-I/home/ubuntu/ffmpeg_build/include --extra-ldflags=-L/home/ubuntu/ffmpeg_build/lib --extra-libs='-lpthread -lm' --bindir=/home/ubuntu/bin --enable-gpl --enable-libaom --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-libpulse
#   libavutil      56. 25.100 / 56. 25.100
#   libavcodec     58. 42.104 / 58. 42.104
#   libavformat    58. 25.100 / 58. 25.100
#   libavdevice    58.  6.101 / 58.  6.101
#   libavfilter     7. 46.101 /  7. 46.101
#   libswscale      5.  4.100 /  5.  4.100
#   libswresample   3.  4.100 /  3.  4.100
#   libpostproc    55.  4.100 / 55.  4.100
