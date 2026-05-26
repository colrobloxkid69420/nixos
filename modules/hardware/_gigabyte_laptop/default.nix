{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  eza,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gigabyte-laptop-wmi";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tangalbert919";
    repo = "gigabyte-laptop-wmi";
    tag = finalAttrs.version;
    hash = "sha256-+ZRyrI3PJRIEFEcOrKh9Zuhg07o/YMkycspOBPDAaeU=";
  };

  patchPhase = ''
    runHook prePatch
    cp "${./Makefile}" Makefile
    runHook postPatch
  '';

  makeFlags =
    kernelModuleMakeFlags
    ++ [
      "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "INSTALL_MOD_PATH=${placeholder "out"}"
    ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  meta = {
    description = "Linux kernel module for Gigabyte laptops to interact with the embedded controller";
    homepage = "https://github.com/tangalbert919/gigabyte-laptop-wmi";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [];
  };
})
