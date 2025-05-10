{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  pkg-config,
  autoreconfHook,
  xorg,
  libdrm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-video-armsoc";
  version = "1.4.1";

  # The <nixpkgs/pkgs/servers/x11/xorg/builder.sh> builder must be used, or
  # Failed to load armsoc_drv.so: undefined symbol: "exaDriverAlloc"
  builder = lib.elemAt xorg.xf86videofbdev.args 1;
  hardeningDisable = [
    "bindnow"
    "relro"
  ];
  strictDeps = true;

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    group = "xorg";
    owner = "driver";
    repo = "xf86-video-armsoc";
    rev = finalAttrs.version;
    hash = "sha256-iIfFa/hKKlhkQGHsw74WgJ/+kj7crWo+iQQuwaTK2Lg=";
  };


  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    xorg.utilmacros
    xorg.xorgserver
    libdrm
  ];

  meta = with lib; {
    description = "Open-source X.org graphics driver for ARM graphics (with Xilinx patches)";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-armsoc";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ chuangzhu ];
  };
})
