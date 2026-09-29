{
  core = import ./core;
  desktop = import ./desktop;
  agentdock = import ./agentdock.nix;
  secureboot = import ./secureboot.nix;
  dedsecGrubTheme = import ./dedsec-grub-theme.nix;
}
