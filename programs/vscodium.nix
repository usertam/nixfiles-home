{ config, pkgs, lib, inputs, ... }:

{
  programs.vscodium = {
    enable = true;
    package =
      let
        version = "1.135.06055";
        release = "https://github.com/VSCodium/vscodium/releases/download/${version}";
        pins = {
          aarch64-darwin = {
            inherit version;
            src = pkgs.fetchurl {
              url = "${release}/VSCodium-darwin-arm64-${version}.zip";
              hash = "sha256-Yf+evDrFVjxjoKnhtHmCJkfn8sMwOwYp8V/v6eKR98w=";
            };
            # chmod: cannot access 'Contents/Resources/app/node_modules/@vscode/ripgrep-universal/bin/darwin-arm64/rg': No such file or directory
            postPatch = "";
          };
        };
        pin = pins.${pkgs.stdenv.hostPlatform.system} or null;
      in
      if pin != null && lib.versionOlder pkgs.vscodium.version pin.version then
        pkgs.vscodium.overrideAttrs pin
      else
        pkgs.vscodium;

    # Configure extensions, and let them be immutable.
    mutableExtensionsDir = false;
    profiles.default.extensions =
      let
        pkgs' = pkgs.appendOverlays [ inputs.nix-vscode-extensions.overlays.default ];
        extensions = pkgs'.nix-vscode-extensions;
        vscode = extensions.vscode-marketplace-release;
        openvsx = extensions.open-vsx-release;
      in [
        vscode.antfu.icons-carbon
        vscode.azemoh.one-monokai
        vscode.bbenoist.nix
        vscode.foxundermoon.shell-format
        vscode.james-yu.latex-workshop
        vscode.llvm-vs-code-extensions.vscode-clangd
        vscode.ms-python.python
        vscode.pkief.material-icon-theme
        vscode.redhat.vscode-yaml
        vscode.rust-lang.rust-analyzer
        vscode.streetsidesoftware.code-spell-checker
        vscode.tonybaloney.vscode-pets
        vscode.myriad-dreamin.tinymist
        vscode.openai.chatgpt
        vscode.anthropic.claude-code
        vscode.github.copilot-chat
        openvsx.jeanp413.open-remote-ssh
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
      # Deny chord keybindings; fix mac option+arrow + nano keybindings.
      "terminal.integrated.allowChords" = false;
      "terminal.integrated.macOptionIsMeta" = true;
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
      "extensions.autoUpdate" = "off";
      # Configure Github Copilot.
      "chat.disableAIFeatures" = false;
      "github.copilot.editor.enableAutoCompletions" = true;
      "github.copilot.enable" = {
        "plaintext" = false;
        "scminput" = false;
        "markdown" = true;  # Default is false.
        "*" = true;
      };
      "claudeCode.preferredLocation" = "panel";
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
      # Enable git blame inline.
      "git.blame.editorDecoration.enabled" = true;
      "workbench.colorCustomizations"."git.blame.editorDecorationForeground" = "#686f7d";
    };
  };

  # Remove directory of vscodium extension symlinks before linking.
  home.activation.resetVSCodium = lib.hm.dag.entryBefore ["linkGeneration"] ''
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG \
        $HOME/.vscode-oss/extensions
  '';
}
