{pkgs}: {
  gitButler = (import ./gitButler.nix) {inherit pkgs;};
  # outro = (import ./outro-pacote.nix) { inherit pkgs; };
}
