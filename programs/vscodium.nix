{ pkgs, lib, inputs, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.overrideAttrs (prev: let
      icns = pkgs.fetchurl {
        url = "https://github.com/VSCodium/vscodium/raw/1.88.1.24104/src/insider/resources/darwin/code.icns";
        hash = "sha256-20pXkb8q0HxZmMFP4WZTFOqt1k1xUKrzBG9AzcTBrEQ=";
      };
    in {
      postInstall = (prev.postInstall or "") + lib.optionalString pkgs.stdenv.isDarwin ''
        # Replace icon with insider icon.
        cp -f ${icns} $out/Applications/VSCodium.app/Contents/Resources/VSCodium.icns
      '';
    });
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = let
      exts = inputs.nix-vscode-extensions.extensions.${pkgs.system};
      market = exts.vscode-marketplace;
    in with market; [
      antfu.icons-carbon
      azemoh.one-monokai
      bbenoist.nix
      eamodio.gitlens
      foxundermoon.shell-format
      github.copilot
      github.copilot-chat
      james-yu.latex-workshop
      llvm-vs-code-extensions.vscode-clangd
      market."4ops".terraform
      mrmlnc.vscode-apache
      ms-python.python
      pkief.material-icon-theme
      redhat.vscode-xml
      redhat.vscode-yaml
      scala-lang.scala
      streetsidesoftware.code-spell-checker
      tonybaloney.vscode-pets
    ];
    userSettings = {
      # Editor font.
      "editor.fontFamily" = "Fira Code";
      "editor.fontWeight" = if pkgs.stdenv.isDarwin then 400 else 500;
      "editor.fontSize" = 15;
      "editor.fontLigatures" = true;
      # Cursor and scroll animations.
      "editor.cursorBlinking" = "solid";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.smoothScrolling" = true;
      # Github Copilot fix.
      "editor.inlineSuggest.enabled" = true;
      # Disable flagging zh-hant unicode symbols.
      "editor.unicodeHighlight.allowedLocales"."zh-hant" = true;
      # Terminal font.
      "terminal.integrated.fontFamily" = "Brass Mono Code";
      "terminal.integrated.fontWeight" = if pkgs.stdenv.isDarwin then 400 else 500;
      "terminal.integrated.fontSize" = 15;
      "terminal.integrated.fontLigatures" = true;
      "terminal.integrated.cursorStyle" = "underline";
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
      # Disable telemetry.
      "redhat.telemetry.enabled" = false;
      # Disable all updates.
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      # Disable Github Copilot on some files.
      "github.copilot.enable" = {
        "plaintext" = false;
        "scminput" = false;
        "markdown" = true;  # Default is false.
        "*" = true;
      };
      # Configure clangd path.
      "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
      # Configure vscode-pets.
      "vscode-pets.petColor" = "white";
      "vscode-pets.petSize" = "small";
      "vscode-pets.throwBallWithMouse" = true;
      # Configure gitlens.
      "gitlens.showWelcomeOnInstall" = false;
      "gitlens.showWhatsNewAfterUpgrades" = false;
      "gitlens.plusFeatures.enabled" = false;
      "gitlens.launchpad.indicator.enabled" = false;
    };
  };

  # Remove directory of vscodium extension symlinks before linking.
  home.activation.resetVSCodium = lib.hm.dag.entryBefore ["linkGeneration"] ''
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG \
        $HOME/.vscode-oss/extensions
  '';
}
