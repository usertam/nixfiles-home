{ pkgs, ... }:

{
  programs.chromium = let
    # configurations for ungoogled-chromium.
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
    preferences = {   # TODO: master_preferences
      "browser"."last_clear_browsing_data_tab" = 1;
      "enable_do_not_track" = true;
      "profile" = {
        "name" = "​";
        "avatar_index" = 55;
        "cookies" = let
          mkCookieEntry = url: {
            "${url}" = {
              "expiration" = "0";
              "last_modified" = "0";
              "model" = 0;
              "setting" = 1;
            };
          };
        in builtins.map mkCookieEntry [
          "[*.]discord.com,*"
          "[*.]github.com,*"
          "[*.]google.com,*"
          "[*.]leetcode.com,*"
          "[*.]lihkg.com,*"
          "[*.]microsoftonline.com,*"
          "[*.]reddit.com,*"
          "[*.]twitch.tv,*"
          "[*.]youtube.com,*"
          "web.whatsapp.com,*"
        ];
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
  in {
    enable = true;
    package = pkgs.ungoogled-chromium.override {
      commandLineArgs = builtins.concatStringsSep " " flags;
    };
    extensions = builtins.map mkExtension extensions;
  };
}
