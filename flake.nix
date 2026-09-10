{
  description = "Termux configuration and supervised Android control workspace";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      perSystem =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          lib = pkgs.lib;
          helperRuntimeInputs = with pkgs; [
            android-tools
            coreutils
            gawk
          ];
          shellTools = with pkgs; [
            android-tools
            scrcpy
            jq
          ];
          device = ''
            device_serial() {
              local devices
              devices="$(adb devices | awk 'NR > 1 && NF { print $1 " " $2 }')"
              local attached=()
              local ready=()
              local serial state
              while read -r serial state; do
                [ -z "''${serial:-}" ] && continue
                attached+=("$serial ($state)")
                case "$state" in
                  device) ready+=("$serial") ;;
                  unauthorized) echo "Android device $serial is unauthorized. Unlock it and accept the USB debugging RSA prompt." >&2 ;;
                  offline) echo "Android device $serial is offline. Reconnect it or restart ADB." >&2 ;;
                  *) echo "Android device $serial has state: $state" >&2 ;;
                esac
              done <<< "$devices"
              if [ "''${#attached[@]}" -gt 1 ]; then
                echo "More than one Android device is attached:" >&2
                printf '  %s\n' "''${attached[@]}" >&2
                echo "Disconnect extra devices or use raw adb -s SERIAL ..." >&2
                return 1
              fi
              case "''${#ready[@]}" in
                1) printf '%s\n' "''${ready[0]}" ;;
                0) echo "No authorized Android device found. Run: adb devices" >&2; return 1 ;;
              esac
            }

            android_adb() {
              adb -s "$(device_serial)" "$@"
            }
          '';
          mkAndroidCommand =
            name: text:
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = helperRuntimeInputs;
              text = ''
                set -o pipefail
                ${device}
                ${text}
              '';
            };
          commands = {
            android-status = mkAndroidCommand "android-status" ''
              serial="$(device_serial)"
              echo "serial: $serial"
              echo "model: $(adb -s "$serial" shell getprop ro.product.model | tr -d '\r')"
              echo "android: $(adb -s "$serial" shell getprop ro.build.version.release | tr -d '\r') (SDK $(adb -s "$serial" shell getprop ro.build.version.sdk | tr -d '\r'))"
              echo "display: $(adb -s "$serial" shell wm size | tr -d '\r' | paste -sd '; ' -)"
              orientation="$(adb -s "$serial" shell dumpsys input | awk -F 'orientation=' '/Viewport INTERNAL:/ { split($2, value, ","); print value[1]; exit }')"
              echo "orientation: ''${orientation:-unknown} (0=natural, 1=90 degrees, 2=180 degrees, 3=270 degrees)"
            '';
            android-screenshot = mkAndroidCommand "android-screenshot" ''
              [ "$#" -le 1 ] || { echo "Usage: android-screenshot [output.png]" >&2; exit 2; }
              output="''${1:-/tmp/android-control/screen.png}"
              mkdir -p "$(dirname "$output")"
              tmp="$output.tmp.$$"
              trap 'rm -f "$tmp"' EXIT
              android_adb exec-out screencap -p > "$tmp"
              [ -s "$tmp" ] || { echo "Screenshot was empty: $output" >&2; exit 1; }
              mv "$tmp" "$output"
              trap - EXIT
              printf '%s\n' "$output"
            '';
            android-ui = mkAndroidCommand "android-ui" ''
              [ "$#" -le 1 ] || { echo "Usage: android-ui [output.xml]" >&2; exit 2; }
              output="''${1:-/tmp/android-control/window.xml}"
              remote=/sdcard/window.xml
              mkdir -p "$(dirname "$output")"
              tmp="$output.tmp.$$"
              cleanup() {
                rm -f "$tmp"
                android_adb shell rm -f "$remote" >/dev/null 2>&1 || true
              }
              trap cleanup EXIT
              android_adb shell uiautomator dump "$remote" >/dev/null
              android_adb exec-out cat "$remote" > "$tmp"
              [ -s "$tmp" ] || { echo "UI dump was empty: $output" >&2; exit 1; }
              mv "$tmp" "$output"
              cleanup
              trap - EXIT
              printf '%s\n' "$output"
            '';
            android-tap = mkAndroidCommand "android-tap" ''
              [ "$#" -eq 2 ] || { echo "Usage: android-tap X Y" >&2; exit 2; }
              android_adb shell input tap "$1" "$2"
            '';
            android-swipe = mkAndroidCommand "android-swipe" ''
              [ "$#" -ge 4 ] && [ "$#" -le 5 ] || { echo "Usage: android-swipe X1 Y1 X2 Y2 [duration-ms]" >&2; exit 2; }
              android_adb shell input swipe "$@"
            '';
            android-type = mkAndroidCommand "android-type" ''
              [ "$#" -eq 1 ] || { echo "Usage: android-type TEXT" >&2; exit 2; }
              # Base64 keeps host and device shells from interpreting spaces, URLs, or paths.
              # shellcheck disable=SC2016 # $(cat) must expand in the remote device shell.
              printf '%s' "$1" | base64 -w 0 | android_adb shell 'base64 -d | input text "$(cat)"'
            '';
            android-key = mkAndroidCommand "android-key" ''
              [ "$#" -eq 1 ] || { echo "Usage: android-key KEYCODE_BACK|KEYCODE_HOME|..." >&2; exit 2; }
              android_adb shell input keyevent "$1"
            '';
            android-open = mkAndroidCommand "android-open" ''
              [ "$#" -eq 1 ] || { echo "Usage: android-open PACKAGE" >&2; exit 2; }
              if ! result="$(android_adb shell monkey -p "$1" -c android.intent.category.LAUNCHER 1 2>&1)"; then
                echo "Could not launch package $1:" >&2
                printf '%s\n' "$result" >&2
                exit 1
              fi
            '';
          };
          toolBundle = pkgs.symlinkJoin {
            name = "android-control-tools";
            paths = lib.attrValues commands;
          };
        in
        {
          packages = commands // {
            default = toolBundle;
          };
          devShells.default = pkgs.mkShell {
            packages = shellTools ++ [ toolBundle ];
            shellHook = ''
              echo "Android control shell. Run android-status, then use scrcpy for supervision."
            '';
          };
        };
    in
    {
      packages = forAllSystems (system: (perSystem system).packages);
      devShells = forAllSystems (system: (perSystem system).devShells);
    };
}
