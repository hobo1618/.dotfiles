{ pkgs, ... }:
let
  t-smart-manager = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "t-smart-tmux-session-manager";
      version = "unstable-2023-01-06";
      rtpFilePath = "t-smart-tmux-session-manager.tmux";
      src = pkgs.fetchFromGitHub {
        owner = "joshmedeski";
        repo = "t-smart-tmux-session-manager";
        rev = "a1e91b427047d0224d2c9c8148fb84b47f651866";
        sha256 = "sha256-HN0hJeB31MvkD12dbnF2SjefkAVgtUmhah598zAlhQs=";
      };
    };
  tmux-nvim = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux.nvim";
      version = "unstable-2023-01-06";
      src = pkgs.fetchFromGitHub {
        owner = "aserowy";
        repo = "tmux.nvim/";
        rev = "57220071739c723c3a318e9d529d3e5045f503b8";
        sha256 = "sha256-zpg7XJky7PRa5sC7sPRsU2ZOjj0wcepITLAelPjEkSI=";
      };
    };
  tmux-browser = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-browser";
      version = "unstable-2023-01-06";
      src = pkgs.fetchFromGitHub {
        owner = "ofirgall";
        repo = "tmux-browser";
        rev = "c3e115f9ebc5ec6646d563abccc6cf89a0feadb8";
        sha256 = "sha256-ngYZDzXjm4Ne0yO6pI+C2uGO/zFDptdcpkL847P+HCI=";
      };
    };

  tmux-super-fingers = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-super-fingers";
      version = "unstable-2023-01-06";
      src = pkgs.fetchFromGitHub {
        owner = "artemave";
        repo = "tmux_super_fingers";
        rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
        sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
      };
    };

in
{
  # TODO: what if this is defined in another file? Merge it!
  # programs.fish = {
  #   shellInit = ''
  #     fish_add_path ${t-smart-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin/
  #   '';
  # };

  # programs.fish.shellInit = ''
  #   if not contains ${t-smart-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin/ $PATH
  #     fish_add_path ${t-smart-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin/
  #   end
  # '';

  home.packages = with pkgs; [
    lsof
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs;
      [
        tmux-nvim
        tmuxPlugins.tmux-thumbs
        # TODO: why do I have to manually set this
        {
          plugin = t-smart-manager;
          extraConfig = ''
            set -g @t-fzf-prompt '  '
            set -g @t-bind "T"
          '';
        }
        {
          plugin = tmux-super-fingers;
          extraConfig = "set -g @super-fingers-key f";
        }

        tmuxPlugins.sensible
        # must be before continuum edits right status bar
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = '' 
            set -g @catppuccin_flavour 'frappe'
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_date_time "%H:%M"
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
          '';
        }
        {
          plugin = tmuxPlugins.vim-tmux-navigator;
        }
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.yank
      ];
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set-option -g default-command "exec fish"

      set-option -g prefix C-a
      unbind-key C-b
      bind-key C-a send-prefix

      set -g mouse on

      # Open new split at cwd of current split
      unbind v
      unbind h
      bind s split-window -h -c "#{pane_current_path}"
      bind v split-window -v -c "#{pane_current_path}"

      # Use vim keybindings in copy mode
      set-window-option -g mode-keys vi

      # Vim-style pane movement
      bind-key -T prefix h select-pane -L
      bind-key -T prefix j select-pane -D
      bind-key -T prefix k select-pane -U
      bind-key -T prefix l select-pane -R

      bind-key -T prefix S choose-session

      # v in copy mode starts making selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # set system clipboard
      set -g @clipboard 'xclip'
      set -g @yank_selection 'clipboard'

      # Make sure tmux grabs these vars from the first graphical client that attaches
      set -g update-environment "DISPLAY XAUTHORITY"

      # Escape turns on copy mode
      bind Escape copy-mode

      # Easier reload of config
      bind r source-file ~/.config/tmux/tmux.conf

      set-option -g status-position top

      # make Prefix p paste the buffer.
      unbind p
      bind p paste-buffer
    '';
  };
}
