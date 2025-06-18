{
  config,
  pkgs,
  ...
}: let
  userName = "ecb";
  homeDirectory = "/home/${userName}";
  stateVersion = "24.05";
in {
  home = {
    username = userName;
    homeDirectory = homeDirectory;
    stateVersion = stateVersion;

    file = {
      # Top Level Files symlinks
      ".zshrc".source = ../../dotfiles/.zshrc;
      ".zshenv".source = ../../dotfiles/.zshenv;
      ".gitconfig".source = ../../dotfiles/.gitconfig;
      ".ideavimrc".source = ../../dotfiles/.ideavimrc;
      ".local/bin/wallpaper".source = ../../dotfiles/.local/bin/wallpaper;

      # Config directories
      ".config/fastfetch".source = ../../dotfiles/.config/fastfetch;
      ".config/kitty".source = ../../dotfiles/.config/kitty;
      ".config/mpv".source = ../../dotfiles/.config/mpv;
      ".config/tmux/tmux.conf".source = ../../dotfiles/.config/tmux/tmux.conf;
      ".config/yazi".source = ../../dotfiles/.config/yazi;

      # Individual config files
      ".config/starship.toml".source = ../../dotfiles/.config/starship.toml;
      ".config/mimeapps.list".source = ../../dotfiles/.config/mimeapps.list;
    };

    packages = [
      pkgs.mpv
      pkgs.appimage-run
      (import ../../scripts/rofi-launcher.nix {inherit pkgs;})
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
    ];
  };

  imports = [
    ../../config/rofi/rofi.nix
    ../../config/wlogout.nix
  ];

  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  programs.home-manager.enable = true;
}
