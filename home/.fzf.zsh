# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ofeks10/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/ofeks10/.fzf/bin"
fi

source <(fzf --zsh)
