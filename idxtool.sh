#!/bin/bash

# COLORS - REFINED THEME
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
C="\e[1;36m"
W="\e[1;37m"
D="\e[1;90m"
N="\e[0m"

# FONKEE CUSTOM BLOCK ART
print_logo() {
    echo -e "${C}"
    echo -e "  ███████╗ ██████╗ ███╗   ██╗██╗  ██╗███████╗███████╗"
    echo -e "  ██╔════╝██╔═══██╗████╗  ██║██║ ██╔╝██╔════╝██╔════╝"
    echo -e "  █████╗  ██║   ██║██╔██╗ ██║█████╔╝ █████╗  █████╗  "
    echo -e "  ██╔══╝  ██║   ██║██║╚██╗██║██╔═██╗ ██╔══╝  ██╔══╝  "
    echo -e "  ██║     ╚██████╔╝██║ ╚████║██║  ██╗███████╗███████╗"
    echo -e "  ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝"
    echo -e "${D}              Powered by ${C}Fonkee${D} | Dev Console v1.0${N}\n"
}

print_header() {
    clear
    print_logo
    echo -e "${C}-------------------------------------------------------${N}\n"
}

print_option() {
    local num="$1"
    local text="$2"
    local color="$3"
    printf "  ${color}> ${W}[${color}$num${W}]  %-32s ${color}>>${N}\n" "$text"
}

print_status() {
    echo -e "\n${C}-------------------------------------------------------${N}"
    echo -e "  ${G}* STATUS:${N} $1"
    echo -e "${C}-------------------------------------------------------${N}\n"
}

# MAIN MENU LOOP
while true; do
    print_header
    
    print_option "1" "GitHub VPS Maker" "$C"
    print_option "2" "IDX Tool Setup" "$C"
    print_option "3" "IDX VPS Maker" "$C"
    print_option "4" "Exit Console" "$R"

    echo -e "\n${C}  +---------------------------------------------------+${N}"
    echo -ne "${C}  +-- Selection [1-4]: ${Y}"
    read op
    echo -ne "${N}"
    
    case $op in
    1)
        clear
        print_logo
        print_status "Launching GitHub VPS Environment..."
        RAM=15000; CPU=4; DISK_SIZE=100G
        CONTAINER_NAME=fonkee_vps; IMAGE_NAME=hopingboyz/debain12
        VMDATA_DIR="$PWD/vmdata"
        mkdir -p "$VMDATA_DIR"
        echo -e "${C}*${W} Config: ${G}$CPU Cores / $RAM MB RAM${N}\n"
        docker run -it --rm --name "$CONTAINER_NAME" --device /dev/kvm -v "$VMDATA_DIR":/vmdata -e RAM="$RAM" -e CPU="$CPU" -e DISK_SIZE="$DISK_SIZE" "$IMAGE_NAME"
        echo -ne "\n${C}*${W} Press Enter to return...${N}"
        read
        ;;
    2)
        clear
        print_logo
        print_status "Initializing IDX Development Setup..."
        cd; rm -rf myapp flutter; mkdir -p vps123/.idx; cd vps123/.idx
        cat <<'EOF' > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = with pkgs; [
    openssl
    coreutils
    cdrkit
    cloud-utils
    qemu_kvm
    qemu
    sshx
    screen
    openssh
    unzip
    git
    sudo
    python3
  ];

  env = {
    EDITOR = "nano";
    TMPDIR = "/tmp";
  };

  idx = {
    extensions = [ "Dart-Code.flutter" "Dart-Code.dart-code" ];
    workspace = {
      onStart = {
        startup = ''
          # Clean up screens first
          screen -wipe 2>/dev/null || true
          killall screen 2>/dev/null || true
          screen -wipe 2>/dev/null || true

          # Create shell-fixes
          cat > ~/.shell-fixes << 'NIXFIX'
[ ! -d "''${TMPDIR:-}" ] && export TMPDIR=/tmp

for _fn in __vsc_prompt_cmd_original __vsc_prompt_cmd __vsc_preexec __vsc_postexec __vsc_preexec_only __vsc_command_output_start __vsc_continuation_start __vsc_continuation_end __vsc_command_complete __vsc_update_cwd; do
  type "$_fn" &>/dev/null || eval "$_fn() { :; }"
done
unset _fn

if [ -n "''${PROMPT_COMMAND:-}" ]; then
  _safe_pc=""
  IFS=';' read -ra _cmds <<< "$PROMPT_COMMAND"
  for _c in "''${_cmds[@]}"; do
    _c=$(echo "$_c" | xargs)
    [ -z "$_c" ] && continue
    _first=$(echo "$_c" | awk '{print $1}')
    if type "$_first" &>/dev/null; then
      [ -n "$_safe_pc" ] && _safe_pc="$_safe_pc;$_c" || _safe_pc="$_c"
    fi
  done
  PROMPT_COMMAND="$_safe_pc"
  unset _safe_pc _cmds _c _first
fi

case "$TERM" in
  dumb|"") export TERM=xterm-256color ;;
esac

: "''${LANG:=en_US.UTF-8}"
export LANG
export LC_ALL="''${LC_ALL:-$LANG}"

export GPG_TTY=$(tty 2>/dev/null || echo /dev/tty)

[ -n "''${SSH_AUTH_SOCK:-}" ] && [ ! -S "$SSH_AUTH_SOCK" ] && unset SSH_AUTH_SOCK

[ -n "''${DISPLAY:-}" ] && ! test -e "/tmp/.X11-unix/X''${DISPLAY#:}" 2>/dev/null && unset DISPLAY

if [ ! -d "''${XDG_RUNTIME_DIR:-}" ]; then
  _xdg="/tmp/runtime-$(id -u)"
  mkdir -p "$_xdg" 2>/dev/null
  chmod 700 "$_xdg" 2>/dev/null
  export XDG_RUNTIME_DIR="$_xdg"
  unset _xdg
fi

[ ! -d "''${HOME:-}" ] && export HOME=$(eval echo "~$(whoami)")

[ -n "$STY" ] && export SHELL="''${SHELL:-/bin/bash}"

[ -f ~/.sshx_link ] && . ~/.sshx_link

true
NIXFIX

          # Create bashrc with auto-display of startup info
          cat > ~/.bashrc << 'BASHRC'
# Source shell fixes
[ -f ~/.shell-fixes ] && . ~/.shell-fixes

# Source sshx link
[ -f ~/.sshx_link ] && . ~/.sshx_link

# Auto-display startup info (only once per session, only in interactive shell)
if [[ $- == *i* ]] && [ -z "$STARTUP_INFO_SHOWN" ]; then
  export STARTUP_INFO_SHOWN=1
  
  # Wait for startup to complete (max 90 seconds)
  _wait_count=0
  while [ ! -f /tmp/startup_complete ] && [ $_wait_count -lt 90 ]; do
    sleep 1
    _wait_count=$((_wait_count + 1))
  done
  
  # Show the info
  if [ -f /tmp/startup_info ]; then
    cat /tmp/startup_info
    # Reload sshx link in case it was updated
    [ -f ~/.sshx_link ] && . ~/.sshx_link
  fi
  unset _wait_count
fi

# Function to get current sshx link
get_sshx_link() {
  if [ -f ~/.sshx_link ]; then
    . ~/.sshx_link
    echo "$SSHX_LINK"
  elif [ -f /tmp/sshx_link ]; then
    cat /tmp/sshx_link
  else
    echo "No sshx link available yet"
  fi
}
BASHRC

          # Also set up zshrc and profile
          cat > ~/.zshrc << 'ZSHRC'
[ -f ~/.shell-fixes ] && . ~/.shell-fixes
[ -f ~/.sshx_link ] && . ~/.sshx_link

if [[ -o interactive ]] && [ -z "$STARTUP_INFO_SHOWN" ]; then
  export STARTUP_INFO_SHOWN=1
  _wait_count=0
  while [ ! -f /tmp/startup_complete ] && [ $_wait_count -lt 90 ]; do
    sleep 1
    _wait_count=$((_wait_count + 1))
  done
  if [ -f /tmp/startup_info ]; then
    cat /tmp/startup_info
    [ -f ~/.sshx_link ] && . ~/.sshx_link
  fi
  unset _wait_count
fi

get_sshx_link() {
  if [ -f ~/.sshx_link ]; then
    . ~/.sshx_link
    echo "$SSHX_LINK"
  elif [ -f /tmp/sshx_link ]; then
    cat /tmp/sshx_link
  else
    echo "No sshx link available yet"
  fi
}
ZSHRC

          cat > ~/.profile << 'PROFILE'
[ -f ~/.shell-fixes ] && . ~/.shell-fixes
[ -f ~/.sshx_link ] && . ~/.sshx_link
PROFILE

          cat > ~/.screenrc << 'SCREENRC'
setenv TMPDIR /tmp
term xterm-256color
defscrollback 10000
shell -$SHELL
startup_message off
SCREENRC

          export TMPDIR=/tmp
          [ -f ~/.shell-fixes ] && . ~/.shell-fixes

          sleep 1

          # Clear old files
          rm -f /tmp/sshx_link /tmp/sshx_output /tmp/startup_info /tmp/startup_complete

          # 1. Start stayawake session with auto-restart (Ctrl+C safe)
          screen -dmS stayawake bash -c '
            source ~/.shell-fixes 2>/dev/null
            RESTART_COUNT=0
            
            while true; do
              RESTART_COUNT=$((RESTART_COUNT + 1))
              echo ""
              echo "=========================================="
              echo "  STAYAWAKE SCRIPT - Run #$RESTART_COUNT"
              echo "  Started at: $(date)"
              echo "  Press Ctrl+C to restart script"
              echo "  Press Ctrl+A then D to detach"
              echo "=========================================="
              echo ""
              
              # Run in subshell so Ctrl+C only kills the script, not the loop
              (
                trap "exit 130" INT
                python3 <(curl -s https://raw.githubusercontent.com/JishnuTheGamer/24-7/refs/heads/main/24)
              )
              EXIT_CODE=$?
              
              if [ $EXIT_CODE -eq 130 ]; then
                echo ""
                echo "=========================================="
                echo "  Script interrupted (Ctrl+C)"
                echo "  Restarting in 3 seconds..."
                echo "=========================================="
              else
                echo ""
                echo "=========================================="
                echo "  Script exited with code: $EXIT_CODE"
                echo "  Restarting in 3 seconds..."
                echo "=========================================="
              fi
              sleep 3
            done
          '

          # 2. Start sshx session with auto-restart and link update notification (Ctrl+C safe)
          screen -dmS sshx bash -c '
            source ~/.shell-fixes 2>/dev/null
            RESTART_COUNT=0
            
            update_sshx_link() {
              local new_link="$1"
              echo "$new_link" > /tmp/sshx_link
              echo "export SSHX_LINK=\"$new_link\"" > ~/.sshx_link
              
              # Update the startup info file with new link
              cat > /tmp/startup_info << INFOEND

==========================================
        STARTUP COMPLETE
==========================================

SSHX Link: $new_link
(Updated at: $(date))

Screen Sessions:
$(screen -ls 2>/dev/null | grep -E "stayawake|sshx|VPS" || echo "  Loading...")

Commands:
  screen -r stayawake  - View keep-alive script
  screen -r sshx       - View sshx session
  screen -r VPS        - View VPS/idxtool session
  
  Detach from screen:  Ctrl+A then D
  Restart script:      Ctrl+C (script restarts, screen stays)
  Get sshx link:       echo \$SSHX_LINK
                       get_sshx_link
                       cat ~/.sshx_link

==========================================
INFOEND
            }
            
            while true; do
              RESTART_COUNT=$((RESTART_COUNT + 1))
              echo ""
              echo "=========================================="
              echo "  SSHX SESSION - Run #$RESTART_COUNT"
              echo "  Started at: $(date)"
              echo "  Press Ctrl+C to restart script"
              echo "  Press Ctrl+A then D to detach"
              echo "=========================================="
              echo ""
              
              # Clear old output
              rm -f /tmp/sshx_output
              
              # Run sshx in subshell so Ctrl+C only kills sshx, not the loop
              (
                trap "exit 130" INT
                sshx 2>&1 | tee /tmp/sshx_output
              ) &
              SSHX_PID=$!
              
              # Wait for and capture new link
              LINK_FOUND=0
              for i in $(seq 1 30); do
                if ! kill -0 $SSHX_PID 2>/dev/null; then
                  break
                fi
                if grep -o "https://sshx.io/s/[^#]*#[^ ]*" /tmp/sshx_output > /tmp/sshx_link_new 2>/dev/null; then
                  NEW_LINK=$(cat /tmp/sshx_link_new | head -1)
                  if [ -n "$NEW_LINK" ]; then
                    update_sshx_link "$NEW_LINK"
                    echo ""
                    echo "=========================================="
                    echo "  NEW SSHX LINK CAPTURED!"
                    echo "  $NEW_LINK"
                    echo "=========================================="
                    echo ""
                    LINK_FOUND=1
                    break
                  fi
                fi
                sleep 1
              done
              
              if [ $LINK_FOUND -eq 0 ]; then
                echo "WARNING: Could not capture sshx link within 30 seconds"
              fi
              
              # Wait for sshx to finish (or be killed by Ctrl+C)
              wait $SSHX_PID 2>/dev/null
              EXIT_CODE=$?
              
              if [ $EXIT_CODE -eq 130 ]; then
                echo ""
                echo "=========================================="
                echo "  sshx interrupted (Ctrl+C)"
                echo "  Restarting in 3 seconds..."
                echo "  A NEW LINK will be generated!"
                echo "=========================================="
              else
                echo ""
                echo "=========================================="
                echo "  sshx exited with code: $EXIT_CODE"
                echo "  Restarting in 3 seconds..."
                echo "  A NEW LINK will be generated!"
                echo "=========================================="
              fi
              sleep 3
            done
          '

          # 3. Start VPS session with auto-restart (Ctrl+C safe)
          screen -dmS VPS bash -c '
            source ~/.shell-fixes 2>/dev/null
            RESTART_COUNT=0
            
            while true; do
              RESTART_COUNT=$((RESTART_COUNT + 1))
              echo ""
              echo "=========================================="
              echo "  VPS/IDXTOOL SCRIPT - Run #$RESTART_COUNT"
              echo "  Started at: $(date)"
              echo "  Press Ctrl+C to restart script"
              echo "  Press Ctrl+A then D to detach"
              echo "=========================================="
              echo ""
              
              # Run in subshell so Ctrl+C only kills the script, not the loop
              (
                trap "exit 130" INT
                bash <(curl -s https://raw.githubusercontent.com/fonkeee/firebase-studio/refs/heads/main/idxtool.sh)
              )
              EXIT_CODE=$?
              
              if [ $EXIT_CODE -eq 130 ]; then
                echo ""
                echo "=========================================="
                echo "  Script interrupted (Ctrl+C)"
                echo "  Restarting in 3 seconds..."
                echo "=========================================="
              else
                echo ""
                echo "=========================================="
                echo "  Script exited with code: $EXIT_CODE"
                echo "  Restarting in 3 seconds..."
                echo "=========================================="
              fi
              sleep 3
            done
          '

          # Wait for sshx link
          SSHX_LINK=""
          for i in $(seq 1 60); do
            if [ -s /tmp/sshx_link ]; then
              SSHX_LINK=$(cat /tmp/sshx_link | head -1)
              echo "export SSHX_LINK=\"$SSHX_LINK\"" > ~/.sshx_link
              break
            fi
            sleep 1
          done

          # Build startup info file
          cat > /tmp/startup_info << INFOEND

==========================================
        STARTUP COMPLETE
==========================================

SSHX Link: ''${SSHX_LINK:-"Loading... run: cat /tmp/sshx_link"}

Screen Sessions:
$(screen -ls 2>/dev/null | grep -E "stayawake|sshx|VPS" || echo "  Loading...")

Commands:
  screen -r stayawake  - View keep-alive script
  screen -r sshx       - View sshx session
  screen -r VPS        - View VPS/idxtool session
  
  Detach from screen:  Ctrl+A then D
  Restart script:      Ctrl+C (script restarts, screen stays)
  Get sshx link:       echo \$SSHX_LINK
                       get_sshx_link
                       cat ~/.sshx_link

NOTE: All scripts auto-restart after 3 seconds if they exit.
      Ctrl+C restarts the script, NOT the screen session.
      If sshx restarts, a NEW link will be generated.

==========================================
INFOEND

          # Mark startup complete
          touch /tmp/startup_complete

          true
        '';
      };
    };
    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "sh"
            "-c"
            "echo '<!DOCTYPE html><html><head></head><body></body></html>' > /tmp/index.html && python3 -m http.server $PORT --bind 0.0.0.0 --directory /tmp"
          ];
          manager = "web";
        };
      };
    };
  };
}
EOF
        echo -e "${G}* .idx/dev.nix generated successfully.${N}"
        echo -ne "\n${C}*${W} Press Enter to return...${N}"
        read
        ;;
    3)
        clear
        print_logo
        print_status "Fetching Remote IDX Script..."
        bash <(curl -s https://raw.githubusercontent.com/fonkeee/firebase-studio/refs/heads/main/vm.sh)
        echo -ne "\n${C}*${W} Press Enter to return...${N}"
        read
        ;;
    4)
        clear
        print_logo
        echo -e "${C}  +---------------------------------------------------+${N}"
        echo -e "${C}  |${W}       Session closed. System Terminated.        ${C}|${N}"
        echo -e "${C}  +---------------------------------------------------+${N}"
        sleep 1.2
        exit 0
        ;;
    *)
        echo -e "${R}! Invalid selection!${N}"
        sleep 1
        ;;
    esac
done
