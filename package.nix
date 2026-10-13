{ lib, stdenv, stdenvNoCC, fetchurl, autoPatchelfHook, makeWrapper, glibc }:

let
  version = "0.8.0-rc.2";
  sources = {
    x86_64-linux = {
      platform = "linux_amd64";
      hash = "sha256-nxlheC7OwaHHOg6rvuQUob+dyWr4fAgFBSRaISoMgKQ=";
    };
    aarch64-linux = {
      platform = "linux_arm64";
      hash = "sha256-sG+ASlVJ2T4/hco5riChmp6U406DmDFQHOlbxaIudmw=";
    };
    x86_64-darwin = {
      platform = "darwin_amd64";
      hash = "sha256-7YDjJGNnsAHFatLLZjDi9d7BMdTf2o4Es7N9uqQq1hQ=";
    };
    aarch64-darwin = {
      platform = "darwin_arm64";
      hash = "sha256-d7PDsn2sZyFtej0AJoMTdq2QBbUXXCfF6eKI6OByi04=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
  runtimeLibraries = lib.optionals stdenv.hostPlatform.isLinux [
    glibc
    stdenv.cc.cc.lib
  ];
in stdenvNoCC.mkDerivation {
  pname = "ipadecrypt";
  inherit version;

  src = fetchurl {
    url = "https://github.com/londek/ipadecrypt/releases/download/v${version}/ipadecrypt_${version}_${source.platform}";
    inherit (source) hash;
  };

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = runtimeLibraries;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/ipadecrypt"
    runHook postInstall
  '';

  # Unicorn is downloaded and dlopened by the release CLI. Its dependencies
  # must remain discoverable even when that library is outside the Nix store.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram "$out/bin/ipadecrypt" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/ipadecrypt --version
    $out/bin/ipadecrypt --help
    runHook postInstallCheck
  '';

  meta = {
    description = "Download, patch, and decrypt IPAs using a jailbroken iOS device";
    homepage = "https://github.com/londek/ipadecrypt";
    license = lib.licenses.mit;
    mainProgram = "ipadecrypt";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
