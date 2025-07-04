{
  config,
  pkgs,
  unstable,
  inputs,
  options,
  ...
}: let
  username = "ecb";
  userDescription = "Eliseu Brito";
  homeDirectory = "/home/${username}";
  hostName = "rudra";
  timeZone = "America/Recife";

  dbeaver-xwayland = pkgs.dbeaver-bin.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [pkgs.makeWrapper];
    postInstall =
      oldAttrs.postInstall
      or ""
      + ''
        wrapProgram $out/bin/dbeaver \
          --set GDK_BACKEND x11 \
          --set QT_QPA_PLATFORM xcb
      '';
  });
in {
  imports = [
    ./hardware-configuration.nix
    ./user.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
    inputs.home-manager.nixosModules.default
    # inputs.hyprlux.nixosModules.default
  ];

  nixpkgs.overlays = [
    # inputs.nixpkgs-f2k.overlays.stdenvs
    # inputs.nixpkgs-f2k.overlays.compositors
    (final: prev: {
      # awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
    })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = ["v4l2loopback"];
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "30%";
    };
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    plymouth.enable = true;
  };

  networking = {
    hostName = hostName;
    networkmanager.enable = true;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
    firewall = {
      allowedTCPPorts = [3131];
      allowedUDPPorts = [3131];
      allowedTCPPortRanges = [
        {
          from = 8060;
          to = 8090;
        }
        {
          # KDE Connect
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 8060;
          to = 8090;
        }
        {
          # KDE Connect
          from = 1714;
          to = 1764;
        }
      ];
    };
  };

  time.timeZone = timeZone;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  stylix = {
    enable = true;
    base16Scheme = {
      base00 = "191724";
      base01 = "1f1d2e";
      base02 = "26233a";
      base03 = "6e6a86";
      base04 = "908caa";
      base05 = "e0def4";
      base06 = "e0def4";
      base07 = "524f67";
      base08 = "eb6f92";
      base09 = "f6c177";
      base0A = "ebbcba";
      base0B = "31748f";
      base0C = "9ccfd8";
      base0D = "c4a7e7";
      base0E = "f6c177";
      base0F = "524f67";
    };
    image = ../../config/assets/back4.jpg;
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      liveRestore = false;
    };
  };

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["ecb"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  programs = {
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
    };

    firefox.enable = false;
    dconf.enable = true;
    fuse.userAllowOther = true;
  };

  # nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = true;
    users.${username} = {
      isNormalUser = true;
      description = userDescription;
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        firefox
      ];
    };
  };

  programs.adb.enable = true;

  xdg.mime.defaultApplications = {
    # Web and HTML
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/chrome" = "zen.desktop";
    "text/html" = "zen.desktop";
    "application/x-extension-htm" = "zen.desktop";
    "application/x-extension-html" = "zen.desktop";
    "application/x-extension-shtml" = "zen.desktop";
    "application/x-extension-xhtml" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";

    # File management
    "inode/directory" = "org.kde.dolphin.desktop";

    # Text editor
    "text/plain" = "nvim.desktop";

    # Terminal
    "x-scheme-handler/terminal" = "kitty.desktop";

    # Videos
    "video/quicktime" = "mpv-2.desktop";
    "video/x-matroska" = "mpv-2.desktop";

    # LibreOffice formats
    "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
    "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
    "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
    "application/vnd.ms-excel" = "libreoffice-calc.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
    "application/msword" = "libreoffice-writer.desktop";
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
    "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";

    # PDF
    "application/pdf" = "zen.desktop";

    # Torrents
    "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
    "x-scheme-handler/magnet" = "org.qbittorrent.qBittorrent.desktop";

    # Other handlers
    "x-scheme-handler/about" = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";
    "x-scheme-handler/postman" = "Postman.desktop";
    "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
  };

  services.redshift = {
    enable = true;

    latitude = "-8.04";
    longitude = "-34.94";
    brightness = {
      day = "1";
      night = "1";
    };
    temperature = {
      day = 2000;
      night = 3700;
    };
  };

  environment.systemPackages =
    (with pkgs; [
      unstable.temporal-cli
      jetbrains.idea-ultimate

      figma-linux
      gimp
      lazydocker
      lazygit
      daytona-bin

      unstable.zed-editor
      awscli2
      terraform

      # Text editors and IDEs
      vim
      ngrok
      zip
      gitkraken
      bruno

      nest-cli
      cz-cli
      bruno
      vscode
      dbeaver-xwayland
      inputs.nixvim.packages.x86_64-linux.default
      pipx
      obs-studio

      gparted
      rclone

      neofetch

      ente-auth

      postman
      # Zen Browser from custom input
      inputs.zen-browser.packages."${system}".default

      # Programming languages and tools
      luarocks
      go
      lua
      python3
      python3Packages.pip
      uv
      nodePackages_latest.pnpm
      # nodePackages_latest.nodejs
      nodejs_20
      bun
      jdk
      maven
      gcc
      jdk8
      cargo

      # Version control and development tools
      git
      gh
      oxker

      # Shell and terminal utilities
      wtf
      openssl
      stow
      wget
      nautilus
      eza
      starship
      kitty
      zoxide
      fzf
      progress
      tree

      unzip
      ranger
      gearlever

      # System monitoring and management
      htop
      btop
      lm_sensors
      inxi
      auto-cpufreq
      nvtopPackages.nvidia

      # Network and internet tools
      aria2
      qbittorrent

      # Audio and video
      pulseaudio
      pavucontrol
      ffmpeg
      mpv
      deadbeef-with-plugins

      # Image and graphics
      hyprpicker
      swww
      hyprlock
      hyprpaper

      # Productivity and office
      obsidian
      spacedrive
      vesktop

      # Browsers
      google-chrome

      # Gaming and entertainment
      stremio

      # System utilities
      libgcc
      bc
      lxqt.lxqt-policykit
      libnotify
      v4l-utils
      ydotool
      pciutils
      socat
      cowsay
      ripgrep
      lshw
      bat
      pkg-config
      brightnessctl
      virt-viewer
      swappy
      appimage-run
      yad
      playerctl
      nh
      ansible

      # Wayland specific
      hyprshot
      hypridle
      grim
      slurp
      waybar
      dunst
      wl-clipboard
      swaynotificationcenter

      # File systems
      ntfs3g
      os-prober

      # Clipboard managers
      cliphist

      # Fun and customization
      #   cmatrix lolcat fastfetch onefetch microfetch

      # Networking
      networkmanagerapplet

      # Music and streaming
      youtube-music
      spotify

      # Miscellaneous
      greetd.tuigreet
    ])
    ++ (with unstable; [
      warp-terminal
    ]);

  fonts.packages = with pkgs; [
    noto-fonts-emoji
    fira-sans
    roboto
    noto-fonts-cjk-sans
    font-awesome
    material-icons
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
  };

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
  };

  services = {
    libinput = {
      enable = true;

      touchpad = {
        naturalScrolling = true;
        additionalOptions = ''MatchIsTouchpad "on"'';
      };
    };
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      xkb = {
        layout = "us";
        variant = "intl";
      };
    };
    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          user = username;
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd Hyprland";
        };
      };
    };
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
      '';
    };
    supergfxd.enable = true;
    cron = {
      enable = true;
    };
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    flatpak.enable = true;
    printing = {
      enable = true;
      drivers = [pkgs.hplipWithPlugin];
    };
    auto-cpufreq.enable = true;
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
    syncthing = {
      enable = true;
      user = username;
      dataDir = homeDirectory;
      configDir = "${homeDirectory}/.config/syncthing";
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };

  systemd.services = {
    flatpak-repo = {
      path = [pkgs.flatpak];
      script = "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
  };

  hardware = {
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    pulseaudio.enable = false;
    graphics.enable = true;
  };

  services.blueman.enable = true;

  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users")
              && (
                action.id == "org.freedesktop.login1.reboot" ||
                action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                action.id == "org.freedesktop.login1.power-off" ||
                action.id == "org.freedesktop.login1.power-off-multiple-sessions"
              )
            )
          {
            return polkit.Result.YES;
          }
        })
      '';
    };
    pam.services.swaylock.text = "auth include login";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  programs.hyprland.enable = true;
  programs.kdeconnect.enable = true;

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.${username} = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  system.stateVersion = "24.05";
}
