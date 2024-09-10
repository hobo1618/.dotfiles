{ pkgs, ... }:
# https://stackoverflow.com/questions/58597852/can-fish-shells-autosuggestion-keybindings-be-customized
{
  programs.fish = {
    enable = true;
    shellAliases = {
      c = "clear";
      e = "exit";
      vim = "nvim";
      ls = "eza";
    };
    functions.fish_user_key_bindings = ''
      fish_default_key_bindings
      bind \cn history-search-forward
      bind \cp history-search-backward
    '';
  };
}
