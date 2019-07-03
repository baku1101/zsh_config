# Setup fzf
# ---------
if [[ ! "$PATH" == */home/watanabe/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/watanabe/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/watanabe/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/watanabe/.fzf/shell/key-bindings.zsh"
