if [ ! -d $HOME/.fzf ]; then
	echo "download and install fzf ..."
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	$HOME/.fzf/install
fi
export FZF_DEFAULT_COMMAND=""
export FZF_DEFAULT_OPTS=""
export FZF_CTRL_R_OPTS=""
export FZF_ALT_C_OPTS=""

_gen_fzf_default_opts() {
  local base03="234"
  local base02="235"
  local base01="240"
  local base00="241"
  local base0="244"
  local base1="245"
  local base2="254"
  local base3="230"
  local yellow="136"
  local orange="166"
  local red="160"
  local magenta="125"
  local violet="61"
  local blue="33"
  local cyan="37"
  local green="64"

  # Comment and uncomment below for the light theme.

  # Solarized Dark color scheme for fzf
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --color fg:-1,bg:-1,hl:$blue,fg+:$base2,bg+:$base02,hl+:$blue --color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow"
  ## Solarized Light color scheme for fzf
  #export FZF_DEFAULT_OPTS="
  #  --color fg:-1,bg:-1,hl:$blue,fg+:$base02,bg+:$base2,hl+:$blue
  #  --color info:$yellow,prompt:$yellow,pointer:$base03,marker:$base03,spinner:$yellow
  #"
}
_gen_fzf_default_opts

# fzfの設定
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 40% --reverse --border --ansi"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# fkill - kill process
fkill() {
  local pid
  pid=$(ps aux | fzf | awk '{ print $2 }')

  if [ "x$pid" != "x" ]
  then
    BUFFER="kill $pid"
    zle accept-line
  fi
  zle reset-prompt
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 --bind=ctrl-r:toggle-sort\
	  --preview 'bat  --color=always --style=header,grid --line-range :100 {}'))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null \
	  | fzf +m --bind=ctrl-r:toggle-sort) &&
  cd "$dir"
}

fresource() {
	local dir
	dir=$(du -d 1 -ba | sort -rn | numfmt --to=iec --suffix=B --padding=5 | fzf --bind=ctrl-r:toggle-sort| awk '{ print $2 }') &&
	cd "$dir"
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-r:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fzf-cdr
alias cdd='fzf-cdr'
function fzf-cdr() {
	target_dir=$(cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf)
	target_dir=$(echo ${target_dir/\~/$HOME})
    if [ -n "$target_dir" ]; then
        cd $target_dir
    fi
	zle reset-prompt
    # target_dir=`echo ${target_dir/\~/$HOME}`
    # if [ -n "$target_dir" ]; then
    #     cd $target_dir
    # fi
}

fadd() {
  local out q n addfiles
  while out=$(
      git status --short |
      awk '{if (substr($0,2,1) !~ / /) print $2}' |
      fzf-tmux --multi --exit-0 --expect=ctrl-d); do
    q=$(head -1 <<< "$out")
    n=$[$(wc -l <<< "$out") - 1]
    addfiles=(`echo $(tail "-$n" <<< "$out")`)
    [[ -z "$addfiles" ]] && continue
    if [ "$q" = ctrl-d ]; then
      git diff --color=always $addfiles | less -R
    else
      git add $addfiles
    fi
  done
}

alias co='git checkout $(git branch -a | tr -d " " |fzf --height 100% --prompt "CHECKOUT BRANCH>" --preview "git log --color=always {}" \
	| head -n 1 | sed -e "s/^\*\s*//g" | perl -pe "s/remotes\/origin\///g")'
zle -N fkill
bindkey '^xk' fkill
bindkey '^x^k' fkill
zle -N fzf-cdr
bindkey '^x^r' fzf-cdr
