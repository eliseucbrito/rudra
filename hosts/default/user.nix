{ lib, config, pkgs, ... }:

let
  userName = "ecb";
  userDescription = "Eliseu Brito";
in
{
  options = {
  };
  config = {
    users.users.${userName} = {
      isNormalUser = true;
      description = userDescription;
      shell = pkgs.zsh; 
      extraGroups = [ "wheel"  "docker" "wireshark" ];
    };
    programs.zsh.enable = true;
  };
}
