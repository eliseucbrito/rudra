{inputs, ...}: {
  programs.hyprlux = {
    enable = true;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    night_light = {
      enabled = true;
      # Manual sunset and sunrise
      start_time = "00:00";
      end_time = "23:59";
    };

  #   vibrance_configs = [
  #     {
  #       window_class = "steam_app_1172470";
  #       window_title = "Apex Legends";
  #       strength = 100;
  #     }
  #     {
  #       window_class = "cs2";
  #       window_title = "";
  #       strength = 100;
  #     }
  #   ];
  # };
}
