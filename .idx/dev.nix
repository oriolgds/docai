{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = [
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.jdk17
    pkgs.unzip
    pkgs.sudo
  ];

  idx = {
    extensions = [ ];

    workspace = {
      onCreate = {
        create-venv = ''
          python -m venv .venv
          source .venv/bin/activate
          pip install --upgrade pip
          # Option A: explicit packages
          pip install requests
          # Option B: requirements file (uncomment if present)
          # test -f requirements.txt && pip install -r requirements.txt || true
        '';
      };
      onStart = {
        
        auto-activate = ''echo "source .venv/bin/activate" >> ~/.bashrc'';
      };
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
