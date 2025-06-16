{ pkgs, inputs, system, ... }:

# Starship?

let
  # Add the nixpkgs from the 24.05 channel as a flake input
  oldPkgs = import inputs.nixos-24-05 { inherit system; };
  scriptUtils = import ./script-utils.nix { inherit pkgs; };
  ankiWrapped = pkgs.writeShellScriptBin "anki" ''
    #!${pkgs.bash}/bin/bash
    export QT_OPENGL=software
    export QT_QUICK_BACKEND=software
    export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu"
    export QTWEBENGINE_DISABLE_GPU=1
    export QT_QPA_PLATFORM=xcb
    exec ${pkgs.anki}/bin/anki "$@"
  '';
in
{

  imports = [
    ./tmux.nix
    ./fish.nix
    ./neomutt.nix
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
    pinentryPackage = pkgs.pinentry-all;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    ankiWrapped
    cacert
    chatgpt-cli
    chromium
    dig
    discord
    discordo
    docker
    eza
    ffmpeg
    gettext
    gnupg
    inkscape
    inputs.nixvim.packages.${pkgs.system}.default
    isync
    kdePackages.kdenlive
    lua54Packages.luarocks
    lua54Packages.luasocket
    marp-cli
    manim
    msmtp
    mutt-wizard
    nodePackages.nodejs
    nushell
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-backgroundremoval
        obs-shaderfilter
        obs-composite-blur
        obs-scale-to-sound
        obs-source-clone
        obs-move-transition
        obs-gradient-source
        obs-source-switcher
      ];
    })
    oldPkgs.openshot-qt
    pass
    pinentry-all
    poppler_utils
    quickemu
    rclone
    reaper
    rubber
    screenkey
    simplescreenrecorder
    sioyek
    slop
    tectonic
    tldr
    (texlive.withPackages (ps: [
      ps.scheme-full
      # ps.enumitem
    ]))
    # tmux
    v4l-utils
    webcamoid
    yarn
    # Define your Fish script as an executable
    (scriptUtils.mkFishScript "splitmedia" ./scripts/splitmedia.fish)
    (scriptUtils.mkFishScript "pqs" ./scripts/process_question.fish)
    (scriptUtils.mkFishScript "tomov" ./scripts/convert-to-mov.fish)
    (scriptUtils.mkFishScript "toggle-darkmode" ./scripts/toggle-darkmode.fish)
    (scriptUtils.mkFishScript "movtomp4" ./scripts/mov-to-mp4.fish)
    (scriptUtils.mkPythonScript "socr" ./scripts/python/scripts/sat-ocr.py)

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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = { };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
