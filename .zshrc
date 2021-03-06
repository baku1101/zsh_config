# Emacs ライクな操作を有効にする（文字入力中に Ctrl-F,B でカーソル移動など）
# Vi ライクな操作が好みであれば `bindkey -v` とする
bindkey -e

#cdr（最近移動したディレクトリに移動する用)
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
# 自動補完を有効にする
# コマンドの引数やパス名を途中まで入力して <Tab> を押すといい感じに補完してくれる
# 例： `cd path/to/<Tab>`, `ls -<Tab>`
# autoload -U compinit; compinit -u

#XDG Base Directory Speification
export XDG_CONFIG_HOME=~/.config

# 入力したコマンドが存在せず、かつディレクトリ名と一致するなら、ディレクトリに cd する
# 例： /usr/bin と入力すると /usr/bin ディレクトリに移動
setopt auto_cd

# ↑を設定すると、 .. とだけ入力したら1つ上のディレクトリに移動できるので……
# 2つ上、3つ上にも移動できるようにする
alias ...='cd ../..'
alias ....='cd ../../..'

# "~hoge" が特定のパス名に展開されるようにする（ブックマークのようなもの）
# 例： cd ~hoge と入力すると /long/path/to/hogehoge ディレクトリに移動
hash -d hoge=/long/path/to/hogehoge

# cd した先のディレクトリをディレクトリスタックに追加する
# ディレクトリスタックとは今までに行ったディレクトリの履歴のこと
# `cd + -<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd

# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# 拡張 glob を有効にする
# glob とはパス名にマッチするワイルドカードパターンのこと
# （たとえば `mv hoge.* ~/dir` における "*"）
# 拡張 glob を有効にすると # ~ ^ もパターンとして扱われる
# どういう意味を持つかは `man zshexpn` の FILENAME GENERATION を参照
setopt extended_glob

#
# 履歴
#
HISTFILE=~/.zsh_history
# メモリ上に保存される件数（検索できる件数）
HISTSIZE=100000

# ファイルに保存される件数
SAVEHIST=100000

# rootは履歴を残さないようにする
if [ $UID = 0 ]; then
  unset HISTFILE
  SAVEHIST=0
fi

# 履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "^j" history-beginning-search-backward-end
bindkey "^k" history-beginning-search-forward-end

# 履歴を複数の端末で共有する
setopt share_history
 
# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 重複するコマンドは古い法を削除する
setopt hist_ignore_all_dups

# 複数のzshを同時に使用した際に履歴ファイルを上書きせず追加する
setopt append_history

# 履歴ファイルにzsh の開始・終了時刻を記録する
setopt extended_history

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
#setopt hist_verify

# 先頭がスペースで始まる場合は履歴に追加しない
setopt hist_ignore_space

# ファイルに書き出すとき古いコマンドと同じなら無視
#setopt hist_save_no_dups
# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1

# 単語の一部として扱われる文字のセットを指定する
# ここではデフォルトのセットから / を抜いたものとする
# こうすると、 Ctrl-W でカーソル前の1単語を削除したとき、 / までで削除が止まる
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# zinit
if [ ! -e ~/.zinit/bin/zinit.zsh ]; then
	echo "install zinit ..."
	echo "sh -c '$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)'"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

declare -A ZPLGM
# ZPLGM[MUTE_WARNINGS] = 1 # mute message "plugin already registerd"

zinit light mafredri/zsh-async
zinit light sindresorhus/pure
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zinit light zsh-users/zsh-syntax-highlighting
# history関係
zinit light zsh-users/zsh-history-substring-search
# タイプ補完
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light chrissicool/zsh-256color
zinit light seebi/dircolors-solarized
zinit ice from"gh-r" as"program"; zinit load junegunn/fzf-bin
#snippet

# .zshrc.d内の設定ファイルの読み込み
ZSHHOME="${HOME}/.zshrc.d"

if [ -d $ZSHHOME -a -r $ZSHHOME -a \
     -x $ZSHHOME ]; then
    for i in $ZSHHOME/*; do
        [[ ${i##*/} = *.zsh ]] &&
            [ \( -f $i -o -h $i \) -a -r $i ] && . $i
    done
fi

# ls色付け
autoload colors
colors

export LSCOLORS=gxfxcxdxbxegedabagacag
eval $(dircolors $HOME/.zinit/plugins/seebi---dircolors-solarized/dircolors.256dark)

# 補完候補もLS_COLORSに合わせて色が付くようにする
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# lsがカラー表示になるようエイリアスを設定

#エイリアス
alias_set() {
	local cmd=(`echo $2`)
	if type ${cmd[1]} > /dev/null 2>&1; then
		alias $1=$2
	else
		echo "alias $1='$2' can't set"
	fi
}

spaceToUnderbar() {
	IFS=$'\n'; for A in $(ls --color=never | grep " ") ; do mv $A "$(echo $A | sed -e s/" "/_/g)" ; done
}

alias_set cl "clang++-9 -std=c++14 -Wall -Wno-unused-const-variable -g -fsanitize=undefined -D_GLIBCXX_DEBUG"
#alias cl='clang++-9 -std=c++14 -Wall -Wno-unused-const-variable -g -fsanitize=undefined -D_GLIBCXX_DEBUG'
alias_set clo 'clang++-9 -std=c++14 -Wall -Wno-unused-const-variable -O3'
alias_set cll 'clang-9 -Wall -g'
alias_set cllo 'clang-9 -Wall -O3'
alias_set rm 'trash-put'
alias_set excel 'et'
alias_set vim 'nvim'
alias_set fd 'fdfind'

if `type exa >/dev/null 2>&1`; then
	alias ls='exa'
	alias la='exa -a'
	alias ll='exa -lh --git'
else
	case "${OSTYPE}" in
		darwin*)
			# Mac
			alias ls="ls -GF"
			;;
		linux*)
			# Linux
			alias ls='ls -F --color'
			;;
	esac
	alias ll='ls -lh'
	alias la='ls -a'
fi
#cdした後に自動的にlsする
function chpwd() { ls }

# キーマップ用の設定
# ノーパソのキーボードならload_keymap_jp_to_us (default)
# usbキーボード(HHKBを想定)だとload_keymap_usをログイン時に(?)それぞれ実行するようにする
if [ `lsusb 2>&1 | egrep -c 'PFU|HHKB'` -ne 0 ]; then
    source /home/watanabe/bin/load_keymap_us.sh
else
    source /home/watanabe/bin/load_keymap_jp_to_us.sh
fi

#if [ `dropbox status | grep -c "Dropbox isn't running"` -eq 1 ]; then
#	dropbox start 1>/dev/null 2>&1  &
#fi

xkbset ma 200 10 3 1 50
xset r rate 300 25


export PATH=$PATH:/home/watanabe/bin

#zcompile自動化
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
   zcompile ~/.zshrc
fi

# Rustのpathとか設定
export RUST_BACKTRACE=1
#export PATH="$HOME/.cargo/bin:$PATH"

#todo用の環境変数設定
export TODOSAVE="/home/watanabe/Dropbox/アプリ/db_pythonista_synchronator/todo/"
export TODOACHIEVE="/home/watanabe/Dropbox/アプリ/db_pythonista_synchronator/todo/"

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.local/lib/

#ranger用
export EDITOR="nvim"

[ -f $ZSHHOME/.fzf.zsh ] && source $ZSHHOME/.fzf.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# golang用
export GOPATH=$HOME/go
export GOROOT=$( go env GOROOT )
export PATH=$GOPATH/bin:$PATH
export GO111MODULE=on

#modelsim用
export PATH=$PATH:$HOME/intelFPGA/19.1/modelsim_ase/bin
# npmでインストールしたやつのpath
export PATH=$PATH:$HOME/node_modules/.bin

# PATHの重複を削除
typeset -U path PATH

# lldb for python
export PYTHONPATH="/usr/lib/llvm-7/lib/python2.7/site-packages"

#if (type zprof > /dev/null 2>&1) ;then
#  zprof
#fi
