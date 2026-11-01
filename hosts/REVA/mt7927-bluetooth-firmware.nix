{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  _7zz,
  python3,
}:

stdenvNoCC.mkDerivation {
  pname = "gigabyte-mt7927-bluetooth-firmware";
  version = "1.1044.0.556";

  # Driver offered for the X870E AORUS MASTER X3D ICE. Extract data only;
  # none of the Windows executables are run.
  src = fetchurl {
    url = "https://download.gigabyte.com/FileList/Driver/mb_driver_2683_mtk_1.1044.0.556.zip";
    hash = "sha256-3tD74ve671hpg2et2wWhjqoa9lN9apJXIaUDxNrEnFg=";
  };

  nativeBuildInputs = [
    unzip
    _7zz
    python3
  ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    unzip "$src"
    7zz x mb_driver_2683_mtk_1.1044.0.556.exe BT/mtkbt.dat
    python3 - <<'PY'
    import os
    from pathlib import Path
    import struct

    data = Path("BT/mtkbt.dat").read_bytes()
    name = "BT_RAM_CODE_MT6639_2_1_hdr.bin"
    entry = data.find(name.encode() + b"\0")
    if entry < 0:
        raise ValueError("MT6639 Bluetooth firmware entry is missing")
    cursor = entry + len(name)
    while cursor < len(data) and data[cursor] == 0:
        cursor += 1
    if not data[cursor:cursor + 14].isdigit():
        raise ValueError("Invalid firmware timestamp")
    cursor = (cursor + 14 + 3) & ~3
    offset, size = struct.unpack_from("<II", data, cursor)
    if size == 0 or offset + size > len(data):
        raise ValueError("Invalid firmware payload bounds")
    firmware = data[offset:offset + size]
    if firmware[:14] != b"20250926201235" or size != 574421:
        raise ValueError("Unexpected MT6639 firmware build")
    output = Path(os.environ["out"]) / "lib/firmware/mediatek/mt7927" / name
    output.parent.mkdir(parents=True)
    output.write_bytes(firmware)
    PY
    runHook postInstall
  '';

  meta = {
    description = "MT7927 Bluetooth firmware from GIGABYTE's motherboard driver";
    homepage = "https://www.gigabyte.com/Motherboard/X870E-AORUS-MASTER-X3D-ICE/support";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
