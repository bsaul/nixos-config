{ config, pkgs, ... }:

{
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    configs = {
      default = {
        search_shortcut = "CTRL+SHIFT+SPACE";
        keyboard_layout = {
          layout = "us";
        };
      };
    };
    matches = {
      base = {
        matches = [
          {
            trigger = ":zn";
            replace = "{{timestamp}} ";
          }
          {
            trigger = ":nn";
            replace = "---\ntags: []\n---\n";
          }
          {
            trigger = ":eqsetoid";
            replace = "begin\n ? \n≈⟨ ? ⟩\n ? ∎";
          }
          {
            trigger = ":step";
            replace = "\n≈⟨ ? ⟩\n ?";
          }
        ];
      };
      global_vars = {
        global_vars = [
          {
            name = "currentdate";
            type = "date";
            params = { format = "%d/%m/%Y"; };
          }
          {
            name = "currenttime";
            type = "date";
            params = { format = "%R"; };
          }
          {
            name = "timestamp";
            type = "date";
            params = { format = "%Y%m%d%H%M%S"; };
          }
        ];
      };
    };
  };
}
