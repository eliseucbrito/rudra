# modules/awesome/default.nix
{pkgs, ...}: let
  awesome-git = pkgs.awesome.overrideAttrs (oa: {
    version = "git-0f950cb";
    src = pkgs.fetchFromGitHub {
      owner = "awesomeWM";
      repo = "awesome";
      rev = "0f950cb";
      hash = "sha256-GIUkREl60vQ0cOalA37sCgn7Gv8j/9egfRk9emgGm/Y=";
    };
  });
in {
  xsession.windowManager.awesome = {
    enable = true;
    package = awesome-git;
  };
}
