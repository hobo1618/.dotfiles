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
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      obs = "cd ~/Documents/obsidian/";
      courses = "cd ~/Documents/askerra/content/courses/";
    };
    functions.fish_user_key_bindings = ''
      fish_default_key_bindings
      bind \cn history-search-forward
      bind \cp history-search-backward
    '';
    shellInit = ''
      set -Ux fish_user_paths /home/willh/.local/bin $fish_user_paths
      set -x GNUPGHOME ~/.gnupg
      set -x PINENTRY_USER_DATA "USE_CURSES=1"
      set -x GPG_TTY (tty)
      set -x EDITOR vim
      source ~/.dotfiles/.secrets.fish
    '';
  };
}


##  set -x NEO4J_HOME ~/.config/neo4j
