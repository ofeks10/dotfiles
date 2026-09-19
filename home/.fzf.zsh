# Optional standalone fzf integration.
# Home Manager already loads this for the managed Zsh configuration; this file
# remains safe to source from another Zsh setup as well.
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
