{ config, pkgs, ...}:
{
  programs = {
    zsh = { 
      initExtra = ''
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
            symbols+="%F{blue}?%f"
          fi

          if ! git diff --quiet --ignore-submodules 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            symbols+="%F{yellow}!%f"
          fi

          if git rev-parse --abbrev-ref @{u} &>/dev/null; then
            ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
            behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)

            if (( ahead > 0 )); then
              symbols+="%F{green}↑%f"
            fi  
            if (( behind > 0 )); then
              symbols+="%F{green}↓%f"
            fi
          fi

          echo " %F{green}  ''${branch}%f ''${symbols}"
        }

        function precmd() {
          local gitinfo=$(git_prompt_info)
          PROMPT=" %F{blue} %f %F{magenta}%n%f%u:%F{blue}%~%f''${gitinfo}
          %F{green}→%f " 

          # Right prompt section
          local exit_code=$?
          local now_time=$(date +'%H:%M')
          local parts=()

          # Exit code check
          if [[ $exit_code -eq 0 ]]; then
            parts+=("%F{green}✔%f")
          else
            parts+=("%F{red}✗ $exit_code%f")
          fi

          # Timer
          if [[ -n "$CMD_TIMER" ]]; then
            local end_time=$EPOCHREALTIME
            local elapsed=$(( $end_time - $CMD_TIMER ))

            if ((elapsed >= 0.05)); then
              local elapsed_fmt=$(printf "%.2f" "$elapsed")
              parts+=("%F{yellow}''${elapsed_fmt}s%f")
            fi
          fi

          # Current time 
          parts+=("''${now_time}")

          RPROMPT="''${(j: | :)parts}"
        }
      '';
    };
  };
} # ⟦ΔΒ⟧
