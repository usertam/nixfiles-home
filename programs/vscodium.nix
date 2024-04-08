{ pkgs, lib, inputs, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
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
      market."4ops".terraform
      mrmlnc.vscode-apache
      ms-python.python
      ms-vscode.cpptools
      pkief.material-icon-theme
      redhat.vscode-xml
      redhat.vscode-yaml
      scala-lang.scala
      streetsidesoftware.code-spell-checker
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
      # Telemetry.
      "redhat.telemetry.enabled" = false;
      # Disable updates.
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
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
