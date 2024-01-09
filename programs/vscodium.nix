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
      github-copilot-chat = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "copilot-chat";
          publisher = "github";
          version = "0.11.1";
          sha256 = "sha256-H2AIr/797x3cKqIOiqFwntlRvPjriKCPyPRTEOyN8Ik=";
        };
        meta.license = lib.licenses.unfree;
      };
      terraform = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "terraform";
          publisher = "4ops";
          version = "0.2.5";
          sha256 = "sha256-y5LljxK8V9Fir9EoG8g9N735gISrlMg3czN21qF/KjI=";
        };
        meta.license = lib.licenses.mit;
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
      github-copilot-chat
      eamodio.gitlens
      james-yu.latex-workshop
      pkief.material-icon-theme
      bbenoist.nix
      azemoh-one-monokai
      foxundermoon.shell-format
      terraform
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
      # Allow zh-hant unicode symbols.
      "editor.unicodeHighlight.allowedLocales"."zh-hant" = true;
      # terminal font.
      "terminal.integrated.fontFamily" = "Brass Mono Code";
      "terminal.integrated.fontWeight" = if pkgs.stdenv.isDarwin then 400 else 500;
      "terminal.integrated.fontSize" = 15;
      "terminal.integrated.fontLigatures" = true;
      "terminal.integrated.smoothScrolling" = true;
      # Deny chord keybindings; fix nano keybindings.
      "terminal.integrated.allowChords" = false;
      "terminal.integrated.sendKeybindingsToShell" = true;
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

  # Force regenerate extensions.
  home.activation.resetCodiumExts = {
    after = [ "checkFilesChanged" ];
    before = [ "onFilesChange" ];
    data = ''
      changedFiles['.vscode-oss/extensions/.extensions-immutable.json']=1
    '';
  };
}
