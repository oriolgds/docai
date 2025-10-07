{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = [
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.python311Packages.requests
    pkgs.jdk17
    pkgs.unzip
    pkgs.sudo
    pkgs.android-tools
    pkgs.android-studio-tools
  ];

  idx = {
    extensions = [ ];

    workspace = {
    };

    previews = {
      previews = {
        web = {
          command = [
            "flutter" "run" "--machine" "-d" "web-server"
            "--web-hostname" "0.0.0.0" "--web-port" "$PORT"
          ];
          manager = "flutter";
        };
        android = {
          command = [
            "flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
