{ config, ... }:

{
  programs.htop = {
    enable = true;
    settings = {
      show_program_path = 0;
      screen_tabs = 1;
    }
    // (with config.lib.htop;
      leftMeters [ (text "LeftCPUs2") (text "RightCPUs2") (bar "CPU") ])
    // (with config.lib.htop;
      rightMeters [ (text "Memory") (text "Tasks") (text "LoadAverage") (text "Systemd") (text "Uptime") ]);
  };
}
