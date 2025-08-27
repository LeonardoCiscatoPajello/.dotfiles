{ config, pkgs, ...}:
{
  programs = {
    zsh = { 
      syntaxHighlighting.enable = true;
      initExtra = ''
        # Color codes for your palette
        zmodload zsh/terminfo
        local BLUE='%F{33}'
        local FUCHSIA='%F{197}'      # fuchsia-rose (kitty #BC4A7C)
        local LAVENDER='%F{255}'     # light lavender / white
        local REDWOOD='%F{131}'      # redwood (kitty #A64449)
        local SOFTGRAY='%F{250}'     # soft gray (kitty #b0aeb8)
        local RESET='%f'

        function preexec() {
          export CMD_TIMER=$EPOCHREALTIME
        }

        # Git section

        function git_prompt_info() {
          if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            return
          fi

          local branch dirty ahead behind untracked
          local symbols=""

          branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD)

          if [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
            symbols+="''${BLUE}?''${RESET}"
          fi

          if ! git diff --quiet --ignore-submodules 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            symbols+="''${REDWOOD}!''${RESET}"
          fi

          if git rev-parse --abbrev-ref @{u} &>/dev/null; then
            ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
            behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)

            if (( ahead > 0 )); then
              symbols+="''${FUCHSIA}↑''${RESET}"
            fi
            if (( behind > 0 )); then
              symbols+="''${FUCHSIA}↓''${RESET}"
            fi
          fi

          echo " ''${REDWOOD}  ''${branch}''${RESET}''${symbols}"
        }

        function precmd() {
          local gitinfo=$(git_prompt_info)
          PROMPT=" ''${BLUE}''${RESET} ''${LAVENDER}%n''${RESET}%u:''${FUCHSIA}%~''${RESET}''${gitinfo}
          ''${FUCHSIA}→''${RESET} " 

          # Right prompt section
          local exit_code=$?
          local now_time=$(date +'%H:%M')
          local parts=()

          # Exit code check
          if [[ $exit_code -eq 0 ]]; then
            parts+=("''${FUCHSIA}✔''${RESET}")
          else
            parts+=("''${REDWOOD}✗ $exit_code''${RESET}")
          fi

          # Timer
          if [[ -n "$CMD_TIMER" ]]; then
            local end_time=$EPOCHREALTIME
            local elapsed=$(( $end_time - $CMD_TIMER ))

            if ((elapsed >= 0.05)); then
              local elapsed_fmt=$(printf "%.2f" "$elapsed")
              parts+=("''${SOFTGRAY}''${elapsed_fmt}s''${RESET}")
            fi
          fi

          # Current time 
          parts+=("''${SOFTGRAY}''${now_time}''${RESET}")
          RPROMPT="''${(j: | :)parts}"
        }

        # Zsh Autosuggestions & Syntax Highlighting
         ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555577"
         ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

         typeset -A ZSH_HIGHLIGHT_STYLES
         ZSH_HIGHLIGHT_STYLES[default]="fg=#ddddff"
         ZSH_HIGHLIGHT_STYLES[command]="fg=#a090ff"
         ZSH_HIGHLIGHT_STYLES[arg]="fg=#f7ecfc"

      '';
    };
  };
} # ⟦ΔΒ⟧
