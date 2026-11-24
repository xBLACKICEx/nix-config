# 北通（BEITONG/BETOP）KP 系列手柄，含 KP70B。
#
# 这类手柄上电后先以 XInput 身份枚举，然后等主机发出 Microsoft OS 描述符请求；
# 主线 xpad 不发，固件就断电重连，重试几次后降级成 Switch Pro 手柄——表现为反复
# 掉线、Steam 里变成 Nintendo 手柄、XInput-only 游戏看不到它。补丁让 xpad 在
# probe 阶段补发该请求，把设备锁在 XInput。覆盖 20bc:515f（有线）、20bc:5160（接收器）。
#
# 默认关闭：打开后该 host 每次 rebuild 都要重编内核。
{ config, lib, ... }:
let
  cfg = config.hardware.beitong;
in
{
  options.hardware.beitong.enable = lib.mkEnableOption "北通 KP 系列手柄的 xpad XInput 锁模补丁";

  config.boot.kernelPatches = lib.mkIf cfg.enable [
    {
      name = "xpad-beitong";
      patch = ./patches/xpad-beitong.patch;
    }
  ];
}
