{ lib, pkgs, config, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;

  myHyprCursor = pkgs.stdenv.mkDerivation {
    pname = "myhyprcursor";
    version = "0.1";

    src = pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo  = "hyprcursor";
      rev   = "44e91d467bdad8dcf8bbd2ac7cf49972540980a5";
      sha256 = "sha256-lIqabfBY7z/OANxHoPeIrDJrFyYy9jAM4GQLzZ2feCM=";
    };

    nativeBuildInputs = [ pkgs.ripgrep pkgs.hyprcursor ];

    # Color substitutions (only if those hex codes exist)
    postPatch = ''
      for pair in \
        "#5FA9E6:${c.purple}" \
        "#8FCCFF:${c.purpleBright}" \
        "#4C7CB0:${c.purple}" \
        "#89B4FA:${c.purpleBright}"; do
        from="''${pair%%:*}"; to="''${pair#*:}"
        rg -Il "$from" . | xargs -r sed -i "s/$from/$to/g" || true
      done
    '';

    buildPhase = ''
      runHook preBuild
      THEME_JSON=$(find . -maxdepth 4 -name theme.json | head -1 || true)
      if [ -n "$THEME_JSON" ]; then
        hyprcursor-util --compile "$THEME_JSON" --output build
      else
        echo "No theme.json found (list top-level for debugging):"
        ls -1
      fi
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/icons/MyHypr
      if [ -d build ]; then
        cp -r build/* $out/share/icons/MyHypr/
      else
        # Fallback: copy any 'cursors' dir found
        d=$(find . -type d -name cursors -maxdepth 5 | head -1 || true)
        [ -n "$d" ] && cp -r "$d" $out/share/icons/MyHypr/
      fi
      cat > $out/share/icons/MyHypr/index.theme <<EOF
[Icon Theme]
Name=MyHypr
Comment=Recolored Hypr cursor
Inherits=MyHypr
EOF
      runHook postInstall
    '';
  };
in
{
  options.my.hyprcursor = {
    enable = lib.mkEnableOption "Recolored Hypr cursor";
    size   = lib.mkOption { type = lib.types.int; default = 24; };
  };

  config = lib.mkIf config.my.hyprcursor.enable {
    home.packages = [ myHyprCursor ];

    gtk.cursorTheme = {
      name = "MyHypr";
      size = config.my.hyprcursor.size;
    };

    home.file.".icons/default/index.theme".text = "[Icon Theme]\nInherits=MyHypr\n";

    home.sessionVariables = {
      XCURSOR_THEME = "MyHypr";
      HYPRCURSOR_THEME = "MyHypr";
      XCURSOR_SIZE = toString config.my.hyprcursor.size;
      HYPRCURSOR_SIZE = toString config.my.hyprcursor.size;
    };

    wayland.windowManager.hyprland.settings.env = [
      "XCURSOR_THEME,MyHypr"
      "HYPRCURSOR_THEME,MyHypr"
      "XCURSOR_SIZE,${toString config.my.hyprcursor.size}"
      "HYPRCURSOR_SIZE,${toString config.my.hyprcursor.size}"
    ];
  };
}
