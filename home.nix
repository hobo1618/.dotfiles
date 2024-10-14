{ config, pkgs, inputs, system, ... }:

# Starship?

{
  imports = [
    ./tmux.nix
    ./fish.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "willh";
  home.homeDirectory = "/home/willh";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  services.gpg-agent = {
    enable = true;
    #   pinentryPackage = pkgs.pinentry-curses;
    pinentryPackage = pkgs.pinentry-all;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    docker
    eza
    gnupg
    inputs.nixvim.packages.${pkgs.system}.default
    marp-cli
    nodePackages.nodejs
    nushell
    pass
    #    passff-host
    #   (firefox.override { extraNativeMessagingHosts = [ passff-host ]; })
    #   pinentry-curses
    pinentry-all
    poppler_utils
    quickemu
    screenkey
    slop
    tectonic
    tldr
    tmux
    yarn

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.ripgrep.enable = true;
  programs.git = {
    enable = true;
    userName = "hobo1618";
    userEmail = "hobdenw@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "/home/willh/.dotfiles";
    };
  };

  programs.bun.enable = true;

  programs.pandoc.enable = true;

  #  programs.tmux = {
  #    enable = true;
  #    extraConfig = ''
  #      set-option -g prefix C-a
  #      unbind-key C-b
  #    '';
  #  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/willh/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
