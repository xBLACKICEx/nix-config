{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    fbterm # fbterm is a terminal emulator that supports true color and unicode(to replace tty)
  ];
}
