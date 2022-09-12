{ pkgs, lib, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;
  # builtins.elem (lib.getName pkg) [
  #   "vscode-extension-ms-vscode-cpptools"
  #   "vscode-extension-github-copilot"
  #   "vscode-extension-MS-python-vscode-pylance"
  #   "vscode-extension-visualstudioexptteam-vscodeintellicode"
  # ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = let
      vscodeintellicode = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscodeintellicode";
          publisher = "visualstudioexptteam";
          version = "1.2.21";
          sha256 = "sha256-2zYiAh5unAIjl0fjQtUCO/cPheh/vy2V36xiQfkXU58=";
        };
        meta = {
          license = lib.licenses.unfree;
        };
      };
      one-monokai = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "one-monokai";
          publisher = "azemoh";
          version = "0.5.0";
          sha256 = "sha256-ardM7u9lXkkTTPsDVqTl4yniycERYdwTzTQxaa4dD+c=";
        };
        meta = {
          license = lib.licenses.mit;
        };
      };
    in with pkgs.vscode-extensions; [
      antfu.icons-carbon
      streetsidesoftware.code-spell-checker
      github.copilot
      eamodio.gitlens
      vscodeintellicode
      james-yu.latex-workshop
      pkief.material-icon-theme
      bbenoist.nix
      one-monokai
      ms-python.vscode-pylance
      foxundermoon.shell-format
      redhat.vscode-yaml
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      ms-vscode.cpptools
      ms-python.python
    ];
    userSettings = {
      # Editor font & animations.
      "editor.fontFamily" = "Fira Code";
      "editor.fontWeight" = "500";
      "editor.fontSize" = 15;
      "editor.fontLigatures" = true;
      "editor.cursorBlinking" = "solid";
      "editor.cursorSmoothCaretAnimation" = true;
      "editor.smoothScrolling" = true;
      # Window appearance.
      "window.titleBarStyle" = "custom";
      "workbench.colorTheme" = "One Monokai";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.productIconTheme" = "icons-carbon";
      "workbench.list.smoothScrolling" = true;
      # Workspace trust.
      "security.workspace.trust.banner" = "never";
      "security.workspace.trust.startupPrompt" = "never";
      "security.workspace.trust.untrustedFiles" = "newWindow";
      # Telemetry.
      "redhat.telemetry.enabled" = false;
    };
  };
}
