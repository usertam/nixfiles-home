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
      github-copilot-nightly = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "copilot-nightly";
          publisher = "github";
          version = "1.88.136";
          sha256 = "sha256-5X2KTJs1qIwGzDEbzgXh7SDHTIQJblSt5sUT3deTXwc=";
        };
        meta.license = lib.licenses.unfree;
      };
      github-copilot-labs = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "copilot-labs";
          publisher = "github";
          version = "0.14.884";
          sha256 = "sha256-44t4qdRjw/sdAmO6uW9CaLzs0hJcK+uQnpalCNB8AdM=";
        };
        meta.license = lib.licenses.unfree;
      };
      mrmlnc-vscode-apache = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscode-apache";
          publisher = "mrmlnc";
          version = "1.2.0";
          sha256 = "sha256-wXxgrYnX7YxKQJfzgyV7kpG7wJYE4NOPScT4/BeCv5s=";
        };
        meta.license = lib.licenses.mit;
      };
    in with pkgs.vscode-extensions; [
      antfu.icons-carbon
      streetsidesoftware.code-spell-checker
      github-copilot-nightly
      github-copilot-labs
      eamodio.gitlens
      james-yu.latex-workshop
      pkief.material-icon-theme
      bbenoist.nix
      azemoh-one-monokai
      foxundermoon.shell-format
      redhat.vscode-yaml
      redhat.vscode-xml
      llvm-vs-code-extensions.vscode-clangd
      mrmlnc-vscode-apache
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
      # github copilot.
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = true;
        "scminput" = false;
      };
    };
  };
}
