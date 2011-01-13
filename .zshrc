# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.zsh


# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# Initializes Oh My Zsh

# add a function path
fpath=($ZSH/functions $fpath)

# {{{ alias
# Push and pop directories on directory stack
alias pu='pushd'
alias po='popd'

# Basic directory operations
alias ...='cd ../..'
alias -- -='cd -'

# Super user
alias _='sudo'

#alias g='grep -in'

# Show history
alias history='fc -l 1'

# List direcory contents
alias lsa='ls -lah'
alias l='ls -la'
alias ll='ls -l'
alias sl=ls # often screw this up

alias afind='ack-grep -il'
# }}}

# {{{
# ls colors
autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
#export LS_COLORS

# Enable ls colors
if [ "$DISABLE_LS_COLORS" != "true" ]
then
  # Find the option for using colors in ls, depending on the version: Linux or BSD
  ls --color -d . &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'
fi

#setopt no_beep
setopt auto_cd
setopt multios
setopt cdablevarS

if [[ x$WINDOW != x ]]
then
    SCREEN_NO="%B$WINDOW%b "
else
    SCREEN_NO=""
fi

# Apply theming defaults
PS1="%n@%m:%~%# "

# git theming default: Variables for theming the git info prompt
ZSH_THEME_GIT_PROMPT_PREFIX="git:("         # Prefix at the very beginning of the prompt, before the branch name
ZSH_THEME_GIT_PROMPT_SUFFIX=")"             # At the very end of the prompt
ZSH_THEME_GIT_PROMPT_DIRTY="*"              # Text to display if the branch is dirty
ZSH_THEME_GIT_PROMPT_CLEAN=""               # Text to display if the branch is clean

# Setup the prompt with pretty colors
setopt prompt_subst
setopt transient_rprompt

# Load the theme
PROMPT=$'%{$fg_bold[yellow]%}[<%n@%{$fg_bold[green]%}%m%{$fg_bold[yellow]%}>][%{$fg[blue]%}%*%{$fg_bold[yellow]%}]%{$reset_color%}%{$fg[white]%}[$fg_bold[yellow]${PWD/#$HOME/~}]%{$reset_color%}$(git_prompt_info)\
%{$fg_bold[yellow]%}$ %{$reset_color%}'

PROMPT2=$'%{$fg_bold[yellow]%}[<%n@%{$fg_bold[green]%}%m%{$fg_bold[yellow]%}>][%{$fg[blue]%}%*%{$fg_bold[yellow]%}]%{$reset_color%}%{$fg[white]%}[$fg_bold[yellow]${PWD/#$HOME/~}]%{$reset_color%}$(git_prompt_info)\
%{$fg_bold[yellow]%}%_$ %{$reset_color%}'


ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

function battery_charge {
    echo `$HOME/bin/battery_charge` 2>/dev/null
}

setopt prompt_subst	# Enables additional prompt extentions
autoload -U colors && colors	# Enables colours

RPROMPT='[%(0?,,<%?> )][%F{cyan}%D{%e.%b.%y %H.%M}%F{white}][$(battery_charge)']

# }}}

# {{{
# fixme - the load process here seems a bit bizarre

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on succesive tab press
setopt complete_in_word
setopt always_to_end

WORDCHARS=''

autoload -U compinit
compinit -i

zmodload -i zsh/complist

## case-insensitive (all),partial-word and then substring completion
if [ "x$CASE_SENSITIVE" = "xtrue" ]; then
  zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unset CASE_SENSITIVE
else
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
fi

zstyle ':completion:*' list-colors ''

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
cdpath=(.)

# use /etc/hosts and known_hosts for hostname completion
[ -r ~/.ssh/known_hosts ] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  "$_ssh_hosts[@]"
  "$_etc_hosts[@]"
  `hostname`
  localhost
)
zstyle ':completion:*:hosts' hosts $hosts

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.oh-my-zsh/cache/

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs

# ... unless we really want to.
zstyle '*' single-ignored show

# }}}


# {{{
setopt correct_all

alias man='nocorrect man'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias mkdir='nocorrect mkdir'
alias gist='nocorrect gist'
alias heroku='nocorrect heroku'
alias ebuild='nocorrect ebuild'
alias hpodder='nocorrect hpodder'
# }}}

# {{{
# Changing/making/removing directory
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups

alias ..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd/='cd /'

alias 1='cd -'
alias 2='cd +2'
alias 3='cd +3'
alias 4='cd +4'
alias 5='cd +5'
alias 6='cd +6'
alias 7='cd +7'
alias 8='cd +8'
alias 9='cd +9'

cd () {
  if   [[ "x$*" == "x..." ]]; then
    cd ../..
  elif [[ "x$*" == "x...." ]]; then
    cd ../../..
  elif [[ "x$*" == "x....." ]]; then
    cd ../../..
  elif [[ "x$*" == "x......" ]]; then
    cd ../../../..
  else
    builtin cd "$@"
  fi
}

alias md='mkdir -p'
alias rd=rmdir

alias d='dirs -v'

# }}}

# {{{
## fixme, i duplicated this in xterms - oops
function title {
  if [[ $TERM == "screen" ]]; then
    # Use these two for GNU Screen:
    print -nR $'\033k'$1$'\033'\\\

    print -nR $'\033]0;'$2$'\a'
  elif [[ ($TERM =~ "^xterm") ]] || [[ ($TERM == "rxvt") ]]; then
    # Use this one instead for XTerms:
    print -nR $'\033]0;'$*$'\a'
  fi
}

function precmd {
  title zsh "$PWD"
}

function preexec {
  emulate -L zsh
  local -a cmd; cmd=(${(z)1})
  title $cmd[1]:t "$cmd[2,-1]"
}

function zsh_stats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

function uninstall_oh_my_zsh() {
  /bin/sh $ZSH/tools/uninstall.sh
}

function upgrade_oh_my_zsh() {
  /bin/sh $ZSH/tools/upgrade.sh
}

function take() {
  mkdir -p $1
  cd $1
}

# }}}

# {{{
# get the name of the branch we are on
function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

parse_git_dirty () {
  if [[ -n $(git status -s 2> /dev/null) ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# get the status of the working tree
git_prompt_status() {
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  echo $STATUS
}

# }}}

#
# Color grep results
# Examples: http://rubyurl.com/ZXv
#
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

# {{{
## Command history configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt hist_find_no_dups # ignore duplication command history list
setopt hist_ignore_all_dups # ignore duplication command history list
setopt share_history # share command history data

setopt hist_verify
setopt inc_append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_space

setopt SHARE_HISTORY
setopt APPEND_HISTORY

# }}}

# {{{
# TODO: Explain what some of this does..
autoload -U compinit
compinit -i

bindkey -e
bindkey '\ew' kill-region
bindkey -s '\el' "ls\n"
bindkey -s '\e.' "..\n"
bindkey '^r' history-incremental-search-backward
bindkey "^[[5~" up-line-or-history
bindkey "^[[6~" down-line-or-history

# make search up and down work, so partially type and hit up/down to find relevant stuff
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

bindkey "^[[H" beginning-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[4~" end-of-line
bindkey ' ' magic-space    # also do history expansion on space

bindkey '^[[Z' reverse-menu-complete


bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word

bindkey '^[[3~' delete-char

# consider emacs keybindings:

#bindkey -e  ## emacs key bindings
#
#bindkey '^[[A' up-line-or-search
#bindkey '^[[B' down-line-or-search
#bindkey '^[^[[C' emacs-forward-word
#bindkey '^[^[[D' emacs-backward-word
#
#bindkey -s '^X^Z' '%-^M'
#bindkey '^[e' expand-cmd-path
#bindkey '^[^I' reverse-menu-complete
#bindkey '^X^N' accept-and-infer-next-history
#bindkey '^W' kill-region
#bindkey '^I' complete-word
## Fix weird sequence that rxvt produces
#bindkey -s '^[[Z' '\t'
#

# }}}

# {{{
## smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

## file rename magick
bindkey "^[m" copy-prev-shell-word

## jobs
setopt long_list_jobs

## pager
export PAGER=less
export LC_CTYPE=en_US.UTF-8

# }}}

# {{{
#! /bin/zsh
# A script to make using 256 colors in zsh less painful.
# P.C. Shyamshankar <sykora@lucentbeing.com>
# Copied from http://github.com/sykora/etc/blob/master/zsh/functions/spectrum/

typeset -Ag FX FG BG

FX=(
    reset     "%{[00m%}"
    bold      "%{[01m%}" no-bold      "%{[22m%}"
    italic    "%{[03m%}" no-italic    "%{[23m%}"
    underline "%{[04m%}" no-underline "%{[24m%}"
    blink     "%{[05m%}" no-blink     "%{[25m%}"
    reverse   "%{[07m%}" no-reverse   "%{[27m%}"
)

for color in {000..255}; do
    FG[$color]="%{[38;5;${color}m%}"
    BG[$color]="%{[48;5;${color}m%}"
done

# }}}

# {{{
case "$TERM" in
  xterm*|rxvt*)
    preexec () {
      print -Pn "\e]0;%n@%m: $1\a"  # xterm
    }
    precmd () {
      print -Pn "\e]0;%n@%m: %~\a"  # xterm
    }
    ;;
  screen*)
    preexec () {
      local CMD=${1[(wr)^(*=*|sudo|ssh|-*)]}
      echo -ne "\ek$CMD\e\\"
      print -Pn "\e]0;%n@%m: $1\a"  # xterm
    }
    precmd () {
      echo -ne "\ekzsh\e\\"
      print -Pn "\e]0;%n@%m: %~\a"  # xterm
    }
    ;;
esac

# }}}

# {{{

# Color grep results
# Examples: http://rubyurl.com/ZXv
#
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'
 
# }}}

# {{{
## Command history configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt hist_find_no_dups # ignore duplication command history list
setopt hist_ignore_all_dups # ignore duplication command history list
setopt share_history # share command history data

setopt hist_verify
setopt inc_append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_space

setopt SHARE_HISTORY
setopt APPEND_HISTORY

# }}}

#{{{
# Aliases
alias g='git'
alias gst='git status'
alias gl='git pull'
alias gup='git fetch && git rebase'
alias gp='git push'
alias gd='git diff | mate'
alias gdv='git diff -w "$@" | vim -R -'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gb='git branch'
alias gba='git branch -a'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias glg='git log --stat --max-count=5'

# Git and svn mix
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'

#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

# these aliases take advangate of the previous function
alias ggpull='git pull origin $(current_branch)'
alias ggpush='git push origin $(current_branch)'
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'

#}}}


fpath=($HOME/.zsh/ $fpath)
autoload -U compinit
compinit -i

# functions {{{

function cl() { cd "$@" && l; }
function cs () {
  cd "$@"
  if [ -n "$(git status 2>/dev/null)" ]; then
    echo "$(git status 2>/dev/null)"
  fi
}
function mkd() {
  mkdir -p "$*" && cd "$*" && pwd
}

function gco {
  if [ -z "$1" ]; then
    git checkout master
  else
    git checkout $1
  fi
}

# autojump
j() {
  # change jfile if you already have a .j file for something else
  local jfile=$HOME/.j
  if [ "$1" = "--add" ]; then
    shift
    # we're in $HOME all the time, let something else get all the good letters
    [ "$*" = "$HOME" ] && return
    awk -v q="$*" -F"|" '
    $2 >= 1 { 
      if( $1 == q ) { l[$1] = $2 + 1; found = 1 } else l[$1] = $2
      count += $2
    }
    END {
      found || l[q] = 1
      if( count > 1000 ) {
        for( i in l ) print i "|" 0.9*l[i] # aging
      } else for( i in l ) print i "|" l[i]
    }
    ' $jfile 2>/dev/null > $jfile.tmp
    mv -f $jfile.tmp $jfile
  elif [ "$1" = "" -o "$1" = "--l" ];then
    shift
    awk -v q="$*" -F"|" '
      BEGIN { split(q,a," ") }
      { for( i in a ) $1 !~ a[i] && $1 = ""; if( $1 ) print $2 "\t" $1 }
    ' $jfile 2>/dev/null | sort -n
    # for completion
  elif [ "$1" = "--complete" ];then
    awk -v q="$2" -F"|" '
      BEGIN { split(substr(q,3),a," ") }
      { for( i in a ) $1 !~ a[i] && $1 = ""; if( $1 ) print $1 }
    ' $jfile 2>/dev/null
    # if we hit enter on a completion just go there (ugh, this is ugly)
  elif [[ "$*" =~ "/" ]]; then
    local x=$*; x=/${x#*/}; [ -d "$x" ] && cd "$x"
  else
    # prefer case sensitive
    local cd=$(awk -v q="$*" -F"|" '
      BEGIN { split(q,a," ") }
      { for( i in a ) $1 !~ a[i] && $1 = ""; if( $1 ) { print $2 "\t" $1; x = 1 } }
      END {
        if( x ) exit
        close(FILENAME)
        while( getline < FILENAME ) {
          for( i in a ) tolower($1) !~ tolower(a[i]) && $1 = ""
          if( $1 ) print $2 "\t" $1
        }
    }
    ' $jfile 2>/dev/null | sort -nr | head -n 1 | cut -f 2)
    [ "$cd" ] && cd "$cd"
  fi
}

extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xvjf $1 ;;
      *.tar.gz) tar xvzf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) rar x $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xvf $1 ;;
      *.tbz2) tar xvjf $1 ;;
      *.tgz) tar xvzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *) echo "don't know how to extract '$1'..." ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

# hack & ship
function current_git_branch {
  git branch 2> /dev/null | grep '\*' | awk '{print $2}'
}

hack()
{
  CURRENT=$(current_git_branch)
  git checkout master
  git pull origin master
  git checkout ${CURRENT}
  git rebase master
  unset CURRENT
}
 
ship()
{
  CURRENT=$(current_git_branch)
  git checkout master
  git merge ${CURRENT}
  git push origin master
  git checkout ${CURRENT}
  unset CURRENT
}

function pswhich {
  for i in $*; do
    grepstr=[${i[1,2]}]${i[2,${#i}]}
    tmp=`ps axwww | grep $grepstr | awk '{print $1}'`
    echo "${i}: ${tmp/\\n/,}"
  done
}

function cdgem {
  cd /opt/local/lib/ruby/gems/1.8/gems/; cd `ls|grep $1|sort|tail -1`
}

function cdpython {
  cd /Library/Frameworks/Python.framework/Versions/2.4/lib/python2.4/site-packages/;
}

function mycd {

    MYCD=/tmp/mycd.txt
    touch ${MYCD}

    typeset -i x
    typeset -i ITEM_NO
    typeset -i i
    x=0

    if [[ -n "${1}" ]]; then
       if [[ -d "${1}" ]]; then
          print "${1}" >> ${MYCD}
          sort -u ${MYCD} > ${MYCD}.tmp
          mv ${MYCD}.tmp ${MYCD}
          FOLDER=${1}
       else
          i=${1}
          FOLDER=$(sed -n "${i}p" ${MYCD})
       fi
    fi

    if [[ -z "${1}" ]]; then
       print ""
       cat ${MYCD} | while read f; do
          x=$(expr ${x} + 1)
          print "${x}. ${f}"
       done
       print "\nSelect #"
       read ITEM_NO
       FOLDER=$(sed -n "${ITEM_NO}p" ${MYCD})
    fi

    if [[ -d "${FOLDER}" ]]; then
       cd ${FOLDER}
    fi
}

# mkdir, cd into it
mkcd () {
  mkdir -p "$*"
  cd "$*"
}

calc () { echo "$*" | bc -l; }

# }}}

# program settings & paths {{{
export SCONS_LIB_DIR="/Library/Python/2.6/site-packages/scons-1.2.0-py2.6.egg/scons-1.2.0"
export COPY_EXTENDED_ATTRIBUTES_DISABLE=true

# flex & air
export FLEX_HOME=$HOME/work/tools/flex-3.4.1
export FLEX_SDK=$FLEX_HOME
export FLEX_SDK_HOME=$FLEX_HOME

# tamarin, asc and friends
export TAMARIN_HOME=$HOME/temp/svn_other_projects/lang.tamarin-central
export ASC=$HOME/temp/svn_other_projects/flexsdk/lib/asc.jar
export ASC_COMMAND="java -ea -DAS3 -DAVMPLUS -classpath ${ASC} macromedia.asc.embedding.ScriptCompiler  -abcfuture "
export AVMSHELL_COMMAND=$HOME/temp/svn_other_projects/lang.tamarin-central/__build/shell/avmshell
export AVMSHELL_DEBUG_COMMAND=$HOME/temp/svn_other_projects/lang.tamarin-central/__build_debugger/shell/avmshell

# python
export PYTHONPATH=/opt/local/lib/python2.5/site-packages:$HOME/.python
export PYTHONPATH=$PYTHONPATH:$HOME/.python
export PYTHONSTARTUP=$HOME/.pythonstartup

#ant
export ANT_HOME=$HOME/work/tools/apache-ant-1.7.1
export ANT_OPTS="-Xms256m -Xmx512m"

# maven
export MAVEN_REPO=$HOME/.m2/repository

#export LESS='-fXemPm?f%f .?lbLine %lb?L of %L..:$' # Set options for less command
export LESS="-rX"
export PAGER=less
export EDITOR=g
export GIT_EDITOR=gw
export VISUAL='vim'
export INPUTRC=~/.inputrc
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export VERSIONER_PERL_PREFER_32_BIT=yes
export PERL_BADLANG=0
export DISPLAY=:0.0

# hla
export hlalib=/usr/hla/hlalib
export hlainc=/usr/hla/include

# colors in terminal
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

#GO
export GOROOT=$HOME/temp/svn_other_projects/go
export GOOS=darwin
export GOARCH=amd64
export GOBIN=$HOME/bin/go

export P4CONFIG=.p4conf
export HTML_TIDY=$HOME/.tidyconf
export FCSH_VIM_ROOT=$HOME/work/flex/sdk/bin

export WIKI=$HOME/Documents/personal/life/exploded/

export JAQL_HOME=$HOME/work/saasbase_env/jaql
export HADOOP_HOME=$HOME/work/saasbase_env/hadoop

export ROO_HOME=$HOME/work/tools/spring-roo-1.1.0.M1

export MONO_GAC_PREFIX=/usr/local

# luatext
#export TEXMFCNF=/usr/local/texlive/2008/texmf/web2c/
#export LUAINPUTS='{/usr/local/texlive/texmf-local/tex/context/base,/usr/local/texlive/texmf-local/scripts/context/lua,$HOME/texmf/scripts/context/lua}'
#export TEXMF='{$HOME/.texlive2008/texmf-config,$HOME/.texlive2008/texmf-var,$HOME/texmf,/usr/local/texlive/2008/texmf-config,/usr/local/texlive/2008/texmf-var,/usr/local/texlive/2008/texmf,/usr/local/texlive/texmf-local,/usr/local/texlive/2008/texmf-dist,/usr/local/texlive/2008/texmf.gwtex}'
export TEXMFCACHE=/tmp
#export TEXMFCNF=/usr/local/texlive/2008/texmf/web2c

# java
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home
#export MAVEN_HOME=/usr/share/maven
#export JUNIT_HOME=/usr/share/junit

# haxe
#export HAXE_LIBRARY_PATH=/usr/local/haxe/std:.
#export NEKOPATH=/usr/local/neko


#export M2_HOME=/usr/share/maven
export NOTES=$HOME/Documents/personal/life/notes@/

# }}}

# path {{{
export PATH=\
/usr/local/bin:\
/usr/local/php5/bin:\
$HOME/bin:\
$HOME/bin/binary:\
"/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin":\
"$HOME/Applications/Graphics/Graphviz.app/Contents/MacOS":\
#$HOME/work/tools/apache-maven-3.0/bin/:\
/usr/local/lib/ocaml_godi/bin/:\
"$HOME/Applications/Racket v5.0.1/bin/":\
$HOME/.cabal/bin/:\
$PATH:/usr/hla:\
$HOME/temp/svn_other_projects/sshuttle/:\
$FLEX_HOME/bin:\
/opt/local/bin:\
/opt/local/sbin:\
/opt/local/jruby/bin:\
/usr/local/mysql/bin:\
$HOME/Applications/zero-1.0.0.P20070702-1062:\
$HOME/Applications/dev/Factor:\
$HOME/work/tools/emulator/Vice/tools:\
$HOME/work/tools/gradle-0.9-rc-3/bin/:\
$HOME/bin/go:\
$HOME/work/tools/rhino1_7R2/:\
$HOME/work/tools/nasm/:\
$HOME/temp/svn_other_projects/rock/bin:\
$HOME/.cljr/bin:\
$ROO_HOME/bin:\
$HOME/Applications/emulator/n64/mupen64plus-1.99.4-osx/x86_64/:\
$PATH

export MANPATH=\
/opt/loca/share/man:\
/usr/local/man:\
$MANPATH

export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:\
/usr/local/spidermonkey/lib

export DYLD_FRAMEWORK_PATH=$DYLD_FRAMEWORK_PATH:\
"$HOME/Applications/Racket v5.0.1/lib/"

# }}}

# aliases {{{

# common
alias ack="ack -i -a"
alias vidir="EDITOR=v vidir"
alias vi="v"
alias vim="v"
alias gvim="g"
alias c="clear"
alias l="ls -AGlFT"
alias lt="ls -AGlFTtr"
alias gwhat="grep -e $1"
alias gem="sudo gem"
alias macgem="sudo macgem"
 
# pssh 
alias pssh_mia='pssh -P -l admin -h ~/.pssh/hosts_saasbase_miami'
alias pssh_rtc='pssh -P -l hadoop -h ~/.pssh/hosts_rtc'
alias pscp_rtc='pscp -l hadoop -h ~/.pssh/hosts_rtc'
alias pssh_rtc='pssh -P -l admin -h ~/.pssh/hosts_staging_css'
alias pscp_rtc='pscp -l admin -h ~/.pssh/hosts_staging_css'

# bochs
alias bochs='LTDL_LIBRARY_PATH=$HOME/work/tools/bochs/lib/bochs/plugins BXSHARE=$HOME/work/tools/bochs/share/bochs $HOME/work/tools/bochs/bin/bochs'

#editor
case "$HOSTNAME" in
  $USER-mac*)
  alias gvim='$HOME/Applications/MacVim.app/Contents/MacOS/Vim -g';
  alias vim='$HOME/Applications/MacVim.app/Contents/MacOS/Vim';
  ;;
  sheeva*)
  alias vim='/usr/bin/vim';
  ;;
esac

# git commands
alias gss="git stash save"
alias gsp="git stash pop"
alias gl="git log"
alias ga="git add"
alias gr="git reset"
alias gs="git status"
alias gst="git status"
alias gd="git diff"
alias gdc="git diff --cached"
alias g-update-deleted="git ls-files -z --deleted | git update-index -z --remove --stdin"
alias gb="git branch"
alias gba="git branch -a -v"
alias gfr="git fetch && git rebase refs/remotes/origin/master"
alias gci="git commit"
alias gco="git checkout"

# asc, tamarin
alias asc='$ASC_COMMAND'
alias asc_tamarin='$ASC_COMMAND -import $TAMARIN_HOME/core/builtin.abc'
alias asc_flash='$ASC_COMMAND -import $FLEX_HOME/modules/asc/abc/builtin.abc -import $FLEX_HOME/modules/asc/abc/playerglobal.abc'
alias asc_tamarin_shell='$FLEX_HOME/bin/asc -AS3 -import $TAMARIN_HOME/core/builtin.abc -import $TAMARIN_HOME/shell/shell_toplevel.abc'
alias avm='$AVMSHELL_COMMAND'
alias avm_debug='$AVMSHELL_DEBUG_COMMAND'

# clojure
alias clojure='rlwrap java -cp $MAVEN_REPO/org/clojure/clojure/1.1.0-master-SNAPSHOT/clojure-1.1.0-master-SNAPSHOT.jar:$MAVEN_REPO/org/clojure/clojure-contrib/1.1.0-master-SNAPSHOT/clojure-contrib-1.1.0-master-SNAPSHOT.jar clojure.main'
alias clojure_boot='rlwrap java -Xbootclasspath/a:$MAVEN_REPO/org/clojure/clojure/1.1.0-master-SNAPSHOT/clojure-1.1.0-master-SNAPSHOT.jar:$MAVEN_REPO/org/clojure/clojure-contrib/1.1.0-master-SNAPSHOT/clojure-contrib-1.1.0-master-SNAPSHOT.jar clojure.main'
alias clj='rlwrap java -cp $MAVEN_REPO/org/clojure/clojure/1.1.0-master-SNAPSHOT/clojure-1.1.0-master-SNAPSHOT.jar:$MAVEN_REPO/org/clojure/clojure-contrib/1.1.0-master-SNAPSHOT/clojure-contrib-1.1.0-master-SNAPSHOT.jar clojure.main'
alias ng-server='rlwrap java -cp $MAVEN_REPO/org/clojure/clojure/1.1.0-master-SNAPSHOT/clojure-1.1.0-master-SNAPSHOT.jar:$MAVEN_REPO/org/clojure/clojure-contrib/1.1.0-master-SNAPSHOT/clojure-contrib-1.1.0-master-SNAPSHOT.jar:$MAVEN_REPO/vimclojure/vimclojure/2.2.0-SNAPSHOT/vimclojure-2.2.0-SNAPSHOT.jar com.martiansoftware.nailgun.NGServer 127.0.0.1'

# builtin commands

# make top default to ordering by CPU usage:
alias top='top -ocpu'
# more lightweight version of top which doesn't use so much CPU itself:
alias ttop='top -ocpu -R -F -s 2 -n30'

# ls
alias l="ls -AGlFT"
alias la='ls -A'
alias lt="ls -AGlFTtr"
alias lc="cl"
alias cdd='cd - '
alias mkdir='mkdir -p'
alias reload="source ~/.profile"
alias rc='v ~/.profile && source ~/.profile'
alias finde='find -E'
alias ack="ack -i -a"
alias pgrep='pgrep -lf'
alias df='df -h'
alias du='du -h -c'
alias psa='ps auxwww'
alias ping='ping -c 5'
alias grep='grep --colour'
alias svnaddall='svn status | grep "^\?" | awk "{print \$2}" | xargs svn add'
alias irb='irb --readline -r irb/completion -rubygems'
alias ri='ri -Tf ansi'
alias tu='top -o cpu'
alias tm='top -o vsize'
alias t="~/bin/todo.py -d '$HOME/Documents/personal/life/exploded/todo@/'"

# text 2 html
alias textile='/usr/bin/redcloth'
alias markdown='/usr/local/bin/markdown'

# mathematica
alias math='rlwrap $HOME/Applications/Mathematica.app/Contents/MacOS/MathKernel'

# hadoop, hbase, etc
alias hadoop='$HOME/work/saasbase_env/hadoop/bin/hadoop'
alias hdfs='$HOME/work/saasbase_env/hadoop/bin/hdfs'
alias mapred='$HOME/work/saasbase_env/hadoop/bin/mapred'
alias hbase='$HOME/work/saasbase_env/hbase/bin/hbase'
alias zk='$HOME/work/saasbase_env/zookeeper/bin/zkCli.sh'
alias saasbase='$HOME/work/saasbase_env/saasbase/src/saasbase_thrift/bin/saasbase'
alias psall='pswhich NameNode DataNode TaskTracker JobTracker Quorum HMaster HRegion ThriftServer ReportServer'

# }}}

# {{{ modules
zmodload zsh/datetime
zmodload zsh/stat
zmodload zsh/mathfunc

# }}}

# coloring {{{
#!/usr/bin/env zsh
# -------------------------------------------------------------------------------------------------
# Copyright (c) 2010-2011 zsh-syntax-highlighting contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice, this list of conditions
#    and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice, this list of
#    conditions and the following disclaimer in the documentation and/or other materials provided
#    with the distribution.
#  * Neither the name of the zsh-syntax-highlighting contributors nor the names of its contributors
#    may be used to endorse or promote products derived from this software without specific prior
#    written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# -------------------------------------------------------------------------------------------------
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
# -------------------------------------------------------------------------------------------------


# Token types styles.
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES=(
  default                       'none'
  isearch                       'fg=magenta,standout'
  special                       'fg=magenta,standout'
  unknown-token                 'fg=red,bold'
  reserved-word                 'fg=yellow'
  alias                         'fg=green'
  builtin                       'fg=green'
  function                      'fg=green'
  command                       'fg=green'
  hashed-command                'fg=green'
  path                          'underline'
  globbing                      'fg=blue'
  history-expansion             'fg=blue'
  single-hyphen-option          'none'
  double-hyphen-option          'none'
  back-quoted-argument          'none'
  single-quoted-argument        'fg=yellow'
  double-quoted-argument        'fg=yellow'
  dollar-double-quoted-argument 'fg=cyan'
  back-double-quoted-argument   'fg=cyan'
  bracket-error                 'fg=red,bold'
)

# Colors for bracket levels.
# Put as many color as you wish.
# Leave it as an empty array to disable.
ZSH_HIGHLIGHT_MATCHING_BRACKETS_STYLES=(
  'fg=blue,bold'
  'fg=green,bold'
  'fg=magenta,bold'
  'fg=yellow,bold'
  'fg=cyan,bold'
)

# Tokens that are always immediately followed by a command.
ZSH_HIGHLIGHT_TOKENS_FOLLOWED_BY_COMMANDS=(
  '|' '||' ';' '&' '&&' 'noglob' 'nocorrect' 'builtin'
)

# ZLE highlight types.
zle_highlight=(
  special:$ZSH_HIGHLIGHT_STYLES[special]
  isearch:$ZSH_HIGHLIGHT_STYLES[isearch]
)

# Check if the argument is a path.
_zsh_check-path() {
  [[ -z ${(Q)arg} ]] && return 1
  [[ -e ${(Q)arg} ]] && return 0
  [[ ! -e ${(Q)arg:h} ]] && return 1
  [[ ${#BUFFER} == $end_pos && -n $(print ${(Q)arg}*(N)) ]] && return 0
  return 1
}

# Highlight special chars inside double-quoted strings
_zsh_highlight-string() {
  setopt localoptions noksharrays
  local i j k style
  # Starting quote is at 1, so start parsing at offset 2 in the string.
  for (( i = 2 ; i < end_pos - start_pos ; i += 1 )) ; do
    (( j = i + start_pos - 1 ))
    (( k = j + 1 ))
    case "$arg[$i]" in
      '$')  style=$ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument];;
      "\\") style=$ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]
            (( k += 1 )) # Color following char too.
            (( i += 1 )) # Skip parsing the escaped char.
            ;;
      *)    continue;;
    esac
    region_highlight+=("$j $k $style")
  done
}

# Recolorize the current ZLE buffer.
_zsh_highlight-zle-buffer() {
  # Avoid doing the same work over and over
  [[ ${ZSH_PRIOR_HIGHLIGHTED_BUFFER:-} == $BUFFER ]] && [[ ${#region_highlight} -gt 0 ]] && (( ZSH_PRIOR_CURSOR == CURSOR )) && return
  ZSH_PRIOR_HIGHLIGHTED_BUFFER=$BUFFER
  ZSH_PRIOR_CURSOR=$CURSOR

  setopt localoptions extendedglob bareglobqual
  local new_expression=true
  local start_pos=0
  local highlight_glob=true
  local end_pos arg style
  region_highlight=()
  for arg in ${(z)BUFFER}; do
    local substr_color=0
    [[ $start_pos -eq 0 && $arg = 'noglob' ]] && highlight_glob=false
    ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]##[[:space:]]#}}))
    ((end_pos=$start_pos+${#arg}))
    if $new_expression; then
      new_expression=false
      res=$(LC_ALL=C builtin type -w $arg 2>/dev/null)
      case $res in
        *': reserved')  style=$ZSH_HIGHLIGHT_STYLES[reserved-word];;
        *': alias')     style=$ZSH_HIGHLIGHT_STYLES[alias]
                        local aliased_command="${"$(alias $arg)"#*=}"
                        if [[ ${${ZSH_HIGHLIGHT_TOKENS_FOLLOWED_BY_COMMANDS[(r)$aliased_command]:-}:+yes} = 'yes' && ${${ZSH_HIGHLIGHT_TOKENS_FOLLOWED_BY_COMMANDS[(r)$arg]:-}:+yes} != 'yes' ]]; then
                          ZSH_HIGHLIGHT_TOKENS_FOLLOWED_BY_COMMANDS+=($arg)
                        fi
                        ;;
        *': builtin')   style=$ZSH_HIGHLIGHT_STYLES[builtin];;
        *': function')  style=$ZSH_HIGHLIGHT_STYLES[function];;
        *': command')   style=$ZSH_HIGHLIGHT_STYLES[command];;
        *': hashed')    style=$ZSH_HIGHLIGHT_STYLES[hashed-command];;
        *)              if _zsh_check-path; then
                          style=$ZSH_HIGHLIGHT_STYLES[path]
                        elif [[ $arg[0,1] = $histchars[0,1] ]]; then
                          style=$ZSH_HIGHLIGHT_STYLES[history-expansion]
                        else
                          style=$ZSH_HIGHLIGHT_STYLES[unknown-token]
                        fi
                        ;;
      esac
    else
      case $arg in
        '--'*)   style=$ZSH_HIGHLIGHT_STYLES[double-hyphen-option];;
        '-'*)    style=$ZSH_HIGHLIGHT_STYLES[single-hyphen-option];;
        "'"*"'") style=$ZSH_HIGHLIGHT_STYLES[single-quoted-argument];;
        '"'*'"') style=$ZSH_HIGHLIGHT_STYLES[double-quoted-argument]
                 region_highlight+=("$start_pos $end_pos $style")
                 _zsh_highlight-string
                 substr_color=1
                 ;;
        '`'*'`') style=$ZSH_HIGHLIGHT_STYLES[back-quoted-argument];;
        *"*"*)   $highlight_glob && style=$ZSH_HIGHLIGHT_STYLES[globbing] || style=$ZSH_HIGHLIGHT_STYLES[default];;
        *)       if _zsh_check-path; then
                   style=$ZSH_HIGHLIGHT_STYLES[path]
                 elif [[ $arg[0,1] = $histchars[0,1] ]]; then
                   style=$ZSH_HIGHLIGHT_STYLES[history-expansion]
                 else
                   style=$ZSH_HIGHLIGHT_STYLES[default]
                 fi
                 ;;
      esac
    fi
    [[ $substr_color = 0 ]] && region_highlight+=("$start_pos $end_pos $style")
    [[ ${${ZSH_HIGHLIGHT_TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]:-}:+yes} = 'yes' ]] && new_expression=true
    start_pos=$end_pos
  done

  # Bracket matching
  bracket_color_size=${#ZSH_HIGHLIGHT_MATCHING_BRACKETS_STYLES}
  if ((bracket_color_size > 0)); then
    typeset -A levelpos lastoflevel matching revmatching
    ((level = 0))
    for pos in {1..${#BUFFER}}; do
      case $BUFFER[pos] in
        "("|"["|"{")
          levelpos[$pos]=$((++level))
          lastoflevel[$level]=$pos
          ;;
        ")"|"]"|"}")
          matching[$lastoflevel[$level]]=$pos
          revmatching[$pos]=$lastoflevel[$level]
          levelpos[$pos]=$((level--))
          ;;
      esac
    done
    for pos in ${(k)levelpos}; do
      level=$levelpos[$pos]
      if ((level < 1)); then
        region_highlight+=("$((pos - 1)) $pos "$ZSH_HIGHLIGHT_STYLES[bracket-error])
      else
        region_highlight+=("$((pos - 1)) $pos "$ZSH_HIGHLIGHT_MATCHING_BRACKETS_STYLES[(( (level - 1) % bracket_color_size + 1 ))])
      fi
    done
    ((c = CURSOR + 1))
    if [[ -n $levelpos[$c] ]]; then
      ((otherpos = -1))
      [[ -n $matching[$c] ]] && otherpos=$matching[$c]
      [[ -n $revmatching[$c] ]] && otherpos=$revmatching[$c]
      region_highlight+=("$((otherpos - 1)) $otherpos standout")
    fi
  fi
}

# Special treatment for completion/expansion events:
# For each *complete* function (except 'accept-and-menu-complete'), 
# we create a widget which mimics the original
# and use this orig-* version inside the new colorized zle function (the dot
# idiom used for all others doesn't work right for these functions for some
# reason).  You can see the default setup using "zle -l -L".

# Bind all ZLE events from zle -la to highlighting function.
_zsh_highlight-install() {
  zmodload zsh/zleparameter 2>/dev/null || {
    echo 'zsh-syntax-highlighting:zmoadload error. exiting.' >&2; return -1
  }
  local -a events; : ${(A)events::=${@:#(_*|orig-*|.run-help|.which-command)}}
  local clean_event
  for event in $events; do
    if [[ "$widgets[$event]" == completion:* ]]; then
      eval "zle -C orig-$event ${${${widgets[$event]}#*:}/:/ } ; $event() { builtin zle orig-$event && _zsh_highlight-zle-buffer } ; zle -N $event"
    else
      case $event in
        accept-and-menu-complete)
          eval "$event() { builtin zle .$event && _zsh_highlight-zle-buffer } ; zle -N $event"
          ;;
        .*)
          clean_event=$event[2,${#event}] # Remove the leading dot in the event name
          case ${widgets[$clean_event]-} in
            (completion|user):*)
              ;;
            *)
              eval "$clean_event() { builtin zle $event && _zsh_highlight-zle-buffer } ; zle -N $clean_event"
              ;;
          esac
          ;;
        *)
          ;;
      esac
    fi
  done
}
_zsh_highlight-install "${(@f)"$(zle -la)"}"

# }}}