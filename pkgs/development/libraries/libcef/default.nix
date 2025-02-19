{ lib
, stdenv
, fetchurl
, cmake
, glib
, nss
, nspr
, atk
, at-spi2-atk
, libdrm
, expat
, libxcb
, libxkbcommon
, libX11
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXrandr
, mesa
, gtk3
, pango
, cairo
, alsa-lib
, dbus
, at-spi2-core
, cups
, libxshmfence
}:

let
  rpath = lib.makeLibraryPath [
    glib
    nss
    nspr
    atk
    at-spi2-atk
    libdrm
    expat
    libxcb
    libxkbcommon
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    mesa
    gtk3
    pango
    cairo
    alsa-lib
    dbus
    at-spi2-core
    cups
    libxshmfence
  ];
  platforms = {
    "aarch64-linux" = {
      platformStr = "linuxarm64";
      projectArch = "arm64";
      sha256 = "01ny1k10dklsqrrqmxqd9433413wmpk4ddsmkjp9dzv52dvpcl08";
    };
    "i686-linux" = {
      platformStr = "linux32";
      projectArch = "x86";
      sha256 = "000j6pc336c43xczl1rs5zf8nsf17y76f1kpy14gqgpwyzl8my0w";
    };
    "x86_64-linux" = {
      platformStr = "linux64";
      projectArch = "x86_64";
      sha256 = "1ydjckld89dkpy5zrvk7jjpz70mnlmbm8yinkfpzgcwbkcakk6k7";
    };
  };

  platformInfo = builtins.getAttr stdenv.targetPlatform.system platforms;
in
stdenv.mkDerivation rec {
  pname = "cef-binary";
  version = "96.0.18";
  gitRevision = "fe551e4";
  chromiumVersion = "96.0.4664.110";

  src = fetchurl {
    url = "https://cef-builds.spotifycdn.com/cef_binary_${version}+g${gitRevision}+chromium-${chromiumVersion}_${platformInfo.platformStr}_minimal.tar.bz2";
    inherit (platformInfo) sha256;
  };

  nativeBuildInputs = [ cmake ];
  cmakeFlags = "-DPROJECT_ARCH=${platformInfo.projectArch}";
  makeFlags = [ "libcef_dll_wrapper" ];
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/lib/ $out/share/cef/
    cp libcef_dll_wrapper/libcef_dll_wrapper.a $out/lib/
    cp ../Release/libcef.so $out/lib/
    patchelf --set-rpath "${rpath}" $out/lib/libcef.so
    cp ../Release/*.bin $out/share/cef/
    cp -r ../Resources/* $out/share/cef/
    cp -r ../include $out/
  '';

  meta = with lib; {
    description = "Simple framework for embedding Chromium-based browsers in other applications";
    homepage = "https://cef-builds.spotifycdn.com/index.html";
    maintainers = with maintainers; [ puffnfresh ];
    license = licenses.bsd3;
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
  };
}
