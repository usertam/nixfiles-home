{ pkgs, ... }:

{
  # pile of hacks for ungoogled-chromium.
  # include command line flags, default preferences and extensions.
  programs.chromium = let
    flags = [
      # hardware acceleration configs
      "--disable-features=UseSkiaRenderer,UseChromeOSDirectVideoDecoder"
      "--enable-features=WebUIDarkMode,VaapiVideoDecoder,UseOzonePlatform"
      "--force-dark-mode"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--disable-gpu-driver-bug-workarounds"
      "--enable-native-gpu-memory-buffers"
      # "--ozone-platform=wayland"    # window be gone
      # "--ozone-platform-hint=auto"
      "--password-store=basic"
      # "--use-gl=egl"                # lag die me

      # personal configs
      "--bookmark-bar-ntp=never"
      "--max-connections-per-host=15"
      "--prominent-dark-mode-active-tab-title=true"
      "--show-avatar-button=incognito-and-guest"
    ];
    preferences = {
      "bookmark_bar"."show_on_all_tabs" = false;
      "browser"."last_clear_browsing_data_tab" = 1;
      "default_search_provider_data"."template_url_data" = {
        "date_created" = "0";
        "is_active" = 1;
        "keyword" = "g";
        "last_modified" = "0";
        "short_name" = "Google";
        "suggestions_url" = "https://www.google.com/complete/search?client=chrome&q={searchTerms}";
        "url" = "https://www.google.com/search?q={searchTerms}";
      };
      "enable_do_not_track" = true;
      "profile" = {
        "name" = "​";
        "avatar_index" = 55;
        "content_settings" = {
          "pref_version" = 1;
          "exceptions"."cookies" = let
            meta = {
              "expiration" = "0";
              "last_modified" = "0";
              "model" = 0;
              "setting" = 1;
            };
          in {
            "[*.]discord.com,*" = meta;
            "[*.]github.com,*" = meta;
            "[*.]google.com,*" = meta;
            "[*.]leetcode.com,*" = meta;
            "[*.]lihkg.com,*" = meta;
            "[*.]microsoftonline.com,*" = meta;
            "[*.]reddit.com,*" = meta;
            "[*.]twitch.tv,*" = meta;
            "[*.]youtube.com,*" = meta;
            "ust.space,*" = meta;
            "web.whatsapp.com,*" = meta;
          };
        };
      };
    };
    extensions = [
      {
        name = "just-black";
        id = "aghfnjkcakhmadgdomlmlhhaocbkloab";
        version = "3";
        hash = "sha256-lxRt9N0WgEV1yFmc6p5/SUEvTjafZMYx44wJvxEce7M=";
      }
      {
        name = "ublock-origin";
        id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
        version = "1.43.0";
        hash = "sha256-b18LWcSDTyBrF6qBR1kNfhKwviBsGJ5RyvIusICo9Ec=";
      }
      {
        name = "earth-view-from-google-ea";
        id = "bhloflhklmhfpedakmangadcdofhnnoh";
        version = "3.0.5";
        hash = "sha256-MPbLOXjZoab9CJw91x5mtu59rnyws8W/mdj+I6//Dvs=";
      }
      {
        name = "dark-scrollbar";
        id = "eafmdhegblfeilejhmieheapmlpdeklm";
        version = "1.1";
        hash = "sha256-p1VoVdod1Jlk0ZXufyqYSKKpQGQj3RpKFjgCaC2H3fQ=";
      }
    ];
    # implementations.
    mkExtension = { name, id, version, hash }:
      let
        extension = pkgs.fetchurl {
          inherit hash;
          name = "${name}-${version}.crx";
          url = "https://clients2.google.com/service/update2/crx?response=redirect"
            + "&prodversion=${pkgs.ungoogled-chromium.version}"
            + "&acceptformat=crx2,crx3"
            + "&x=id%3D${id}%26installsource%3Dondemand%26uc";
          curlOpts = "-L";
        };
      in {
        inherit id version;
        crxPath = "${extension}";
      };
    mkChromium = { flags, preferences }:
      (pkgs.ungoogled-chromium.override {
        commandLineArgs = builtins.concatStringsSep " " flags;
      }).overrideAttrs (final: prev: let
        # for some reason prev.browser is not available
        # using pkgs.ungoogled-chromium.browser as substitute
        prev_browser = pkgs.ungoogled-chromium.browser;
      in {
        # overriding the browser will result in a chromium rebuild
        # copying a 300MiB binary over is not ideal but it works
        browser = pkgs.symlinkJoin {
          name = "${prev_browser.name}-pref-${prev_browser.version}";
          paths = [
            (pkgs.writeTextFile {
              name = "initial_preferences";
              destination = "/libexec/chromium/initial_preferences";
              text = builtins.toJSON preferences;
            })
            prev_browser
          ];
          postBuild = ''
            # the chromium binary must be non-symlinked for preferences to work
            rm -f $out/libexec/chromium/chromium
            cp -a ${prev_browser}/libexec/chromium/chromium \
              $out/libexec/chromium/chromium
          '';
        };

        buildCommand = prev.buildCommand + ''
          # redirect wrapper to chromium-unwrapped-pref
          sed -i 's+${prev_browser}+${final.browser}+g' \
            "$out/bin/chromium"
        '';
      });
  in {
    enable = true;
    package = mkChromium { inherit flags preferences; };
    extensions = builtins.map mkExtension extensions;
  };
}
