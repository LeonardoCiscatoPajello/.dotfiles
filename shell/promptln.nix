{ config, pkgs, lib, ... }:
let
  palette = import ../modules/esthetics/palette.nix;
  c = palette.colors;
in
{
  programs.zsh = {
    syntaxHighlighting.enable = true;

    initExtra = lib.mkAfter ''
      # ==============================
      # Unified Prompt (palette-driven)
      # ==============================
      # Build-time color escapes
      local FG='%F{${c.fg}}'
      local DIM='%F{${c.blackBright}}'
      local GOLD='%F{${c.accent}}'
      local GOLD_BRIGHT='%F{${c.yellowBright}}'
      local GREEN='%F{${c.ok}}'
      local RED='%F{${c.error}}'
      local RBRIGHT='%F{${c.redBright}}'
      local BLUE='%F{${c.blue}}'
      local ICE='%F{${c.blueIce}}'
      local IBRIGHT='%F{${c.blueIceBright}}'
      local BBRIGHT='%F{${c.blueBright}}'
      local MAGENTA='%F{${c.accent2}}'
      local MBRIGHT='%F{${c.magentaBright}}'
      local FUCHSIA='%F{${c.fuchsia}}'
      local FBRIGHT='%F{${c.fuchsiaBright}}'
      local PURPLE='%F{${c.purple}}'
      local PBRIGHT='%F{${c.purpleBright}}'
      local RESET='%f'

      # Export palette for other scripts
      export THEME_FG='${c.fg}'
      export THEME_BG='${c.bg}'
      export THEME_ACC='${c.accent}'
      export THEME_ACC2='${c.accent2}'
      export THEME_OK='${c.ok}'
      export THEME_ERR='${c.error}'
      export THEME_WARN='${c.warn}'
      export THEME_INFO='${c.info}'

      zmodload zsh/datetime

      function preexec() {
        CMD_TIMER=$EPOCHREALTIME
      }

      function git_prompt_info() {
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
          return
        fi
        local branch ahead behind
        local symbols=""
        branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

        # Untracked
        if [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
          symbols+="''${IBRIGHT}?''${RESET}"
        fi
        # Dirty
        if ! git diff --quiet --ignore-submodules 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
          symbols+="''${RBRIGHT}!''${RESET}"
        fi
        # Ahead / behind
        if git rev-parse --abbrev-ref @{u} &>/dev/null; then
          ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
          behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
          (( ahead  > 0 )) && symbols+="''${GREEN}↑''${RESET}"
          (( behind > 0 )) && symbols+="''${GREEN}↓''${RESET}"
        fi
        # Stash
        if git rev-parse --verify refs/stash &>/dev/null; then
          symbols+="''${DIM}*''${RESET}"
        fi
        echo " ''${BLUE} ''${branch}''${RESET} ''${symbols}"
      }

      function precmd() {
        local -i ec=$? 
        local gitinfo
        gitinfo=$(git_prompt_info)

        PROMPT=" ''${IBRIGHT}''${RESET} ''${PBRIGHT}%n''${RESET}:''${FUCHSIA}%~''${RESET}''${gitinfo}
        ''${PBRIGHT}→''${RESET} "

        local parts=()

        if [[ $ec -eq 0 ]]; then
          parts+=("''${GREEN}✔''${RESET}")
        else
          parts+=("''${RED}✗ $ec''${RESET}")
        fi

        if [[ -n "$CMD_TIMER" ]]; then
          local end elapsed
          end=$EPOCHREALTIME
          elapsed=$(( end - CMD_TIMER ))
          if (( elapsed >= 0.05 )); then
            local fmt
            fmt=$(printf "%.2f" "$elapsed")
            parts+=("''${FG}''${fmt}s''${RESET}")
          fi
        fi

        parts+=("''${GOLD}''$(date +'%H:%M')''${RESET}")
        RPROMPT="''${(j: | :)parts}"
      }

      # Syntax highlighting (consumes palette)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${c.blackBright}"
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[default]="fg=${c.whiteBright}"
      ZSH_HIGHLIGHT_STYLES[comment]="fg=${c.white}"
      ZSH_HIGHLIGHT_STYLES[command]="fg=${c.blueIce}"
      ZSH_HIGHLIGHT_STYLES[builtin]="fg=${c.blueBright}"
      ZSH_HIGHLIGHT_STYLES[function]="fg=${c.magenta}"
      ZSH_HIGHLIGHT_STYLES[alias]="fg=${c.magentaBright}"
      ZSH_HIGHLIGHT_STYLES[option]="fg=${c.cyanBright}"
      ZSH_HIGHLIGHT_STYLES[path]="fg=${c.accent}"
      ZSH_HIGHLIGHT_STYLES[globbing]="fg=${c.magentaBright}"
      ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${c.error}"
      ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=${c.yellowBright}"
      ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=${c.magenta}"
      ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=${c.accent}"
      ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=${c.cyanBright}"
    '';
  };
} # ⟦ΔΒ⟧
