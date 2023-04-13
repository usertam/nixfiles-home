{ pkgs, lib, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = let
      azemoh-one-monokai = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "one-monokai";
          publisher = "azemoh";
          version = "0.5.0";
          sha256 = "sha256-ardM7u9lXkkTTPsDVqTl4yniycERYdwTzTQxaa4dD+c=";
        };
        meta.license = lib.licenses.mit;
      };
      github-copilot-labs = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "copilot-labs";
          publisher = "github";
          version = "0.12.791";
          sha256 = "sha256-3StswisTiG1e+LZeAuquIXlqaFj0Lzk4WNy+6Af4giw=";
        };
        meta.license = lib.licenses.unfree;
      };
    in with pkgs.vscode-extensions; [
      antfu.icons-carbon
      streetsidesoftware.code-spell-checker
      github.copilot
      github-copilot-labs
      eamodio.gitlens
      james-yu.latex-workshop
      pkief.material-icon-theme
      bbenoist.nix
      azemoh-one-monokai
      foxundermoon.shell-format
      redhat.vscode-yaml
      redhat.vscode-xml
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      ms-vscode.cpptools
      ms-python.python
    ];
    userSettings = {
      # editor font.
      "editor.fontFamily" = "Fira Code";
      "editor.fontWeight" = if pkgs.stdenv.isDarwin then 400 else 500;
      "editor.fontSize" = 15;
      "editor.fontLigatures" = true;
      # editor animations.
      "editor.cursorBlinking" = "solid";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.smoothScrolling" = true;
      # github copilot.
      "editor.inlineSuggest.enabled" = true;
      # terminal font.
      "terminal.integrated.fontWeight" = if pkgs.stdenv.isDarwin then 400 else 500;
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.fontLigatures" = true;
      "terminal.integrated.smoothScrolling" = true;
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
      # Disable updates.
      "update.mode" = "none";
    };
  };
}
