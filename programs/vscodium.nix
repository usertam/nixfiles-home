{ config, pkgs, lib, inputs, ... }:

{
  # Allow unfree packages. Right now the switch is broken.
  # nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.overrideAttrs (prev: {
      postInstall = (prev.postInstall or "") + lib.optionalString pkgs.stdenv.isDarwin ''
        # Replace icon with insider icon.
        cp -f ${pkgs.fetchurl {
          url = "https://github.com/VSCodium/vscodium/raw/${prev.version}/src/insider/resources/darwin/code.icns";
          hash = "sha256-20pXkb8q0HxZmMFP4WZTFOqt1k1xUKrzBG9AzcTBrEQ=";
        }} $out/Applications/VSCodium.app/Contents/Resources/VSCodium.icns
      '';
    });

    # Configure extensions, and let them be immutable.
    mutableExtensionsDir = false;
    profiles.default.extensions = let
      extensions' = inputs.nix-vscode-extensions.extensions;
      markets = extensions'.${pkgs.system}.forVSCodeVersion config.programs.vscode.package.version;
    in with markets.vscode-marketplace; [
      antfu.icons-carbon
      azemoh.one-monokai
      bbenoist.nix
      eamodio.gitlens
      foxundermoon.shell-format
      # Broken hot fix.
      (github.copilot.overrideAttrs (prev: { meta = {}; }))
      james-yu.latex-workshop
      llvm-vs-code-extensions.vscode-clangd
      ms-python.python
      pkief.material-icon-theme
      redhat.vscode-yaml
      rust-lang.rust-analyzer
      streetsidesoftware.code-spell-checker
      tonybaloney.vscode-pets
      myriad-dreamin.tinymist
    ];

    # Disable update checks.
    profiles.default.enableExtensionUpdateCheck = false;
    profiles.default.enableUpdateCheck = false;

    # Configure user settings.
    profiles.default.userSettings = {
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
      # Configure Github Copilot.
      "github.copilot.editor.enableAutoCompletions" = true;
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
      # Configure rust-analyzer path.
      "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    };
  };

  # Remove directory of vscodium extension symlinks before linking.
  home.activation.resetVSCodium = lib.hm.dag.entryBefore ["linkGeneration"] ''
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG \
        $HOME/.vscode-oss/extensions
  '';
}
