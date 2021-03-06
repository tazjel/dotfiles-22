# Notes: ----------------------------------------------------------
# When you start an interactive shell (log in, open terminal or iTerm in OS X,
# or create a new tab in iTerm) the following files are read and run, in this order:
# profile
# bashrc
# .bash_profile
# .bashrc (only because this file is run (sourced) in .bash_profile)
#
# When an interactive shell, that is not a login shell, is started
# (when you run "bash" from inside a shell, or when you start a shell in
# xwindows [xterm/gnome-terminal/etc] ) the following files are read and executed,
# in this order:
# bashrc
# .bashrc
 
bind Space:magic-space
test -r /sw/bin/init.sh && . /sw/bin/init.sh

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

function ps? {
  for i in $*; do
    grepstr=[${i:0:1}]${i:1:${#i}}
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

# completion {{{
# bash completions for j
complete -C 'j --complete "$COMP_LINE"' j

complete -C ~/.bash_completion.d/rake-complete.rb -o default rake
source ~/.bash_completion.d/git-completion.bash
source ~/.bash_completion.d/go
complete -o default -o nospace -F _git gh

# Tab complete for sudo
complete -cf sudo
# type and which complete on commands
complete -c command type which
# builtin completes on builtins
#complete -b builtin
# shopt completes with shopt options
#complete -A shopt shopt
# set completes with set options
complete -A setopt set
# readonly and unset complete with shell variables
complete -v readonly unset
# bg completes with stopped jobs
complete -A stopped -P '%' bg
# other job commands
complete -j -P '%' fg jobs disown

complete -F _todo_sh -o default t

# }}}

# prompt {{{
# Fancy PWD display function
# The home directory (HOME) is replaced with a ~
# /home/me/stuff          -> ~/stuff               if USER=me
# /usr/share/big_dir_name -> ../share/big_dir_name if pwdmaxlen=20
bash_prompt_command() {
  if [ $? -ne 0 ]
  then
    ERROR_FLAG=1
  else
    ERROR_FLAG=
  fi
  # How many characters of the $PWD should be kept
  local pwdmaxlen=25
  # Indicate that there has been dir truncation
  local trunc_symbol=".."
  local dir=${PWD##*/}
  pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
  NEW_PWD=${PWD/#$HOME/\~}
  local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
  if [ ${pwdoffset} -gt "0" ]
  then
      NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
      NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
  fi
}

# prompt
sh_norm="\[\033[0m\]"
sh_black="\[\033[0;30m\]"
sh_darkgray="\[\033[1;30m\]"
sh_blue="\[\033[0;34m\]"
sh_light_blue="\[\033[1;34m\]"
sh_green="\[\033[0;32m\]"
sh_light_green="\[\033[1;32m\]"
sh_cyan="\[\033[0;36m\]"
sh_light_cyan="\[\033[1;36m\]"
sh_red="\[\033[0;31m\]"
sh_light_red="\[\033[1;31m\]"
sh_purple="\[\033[0;35m\]"
sh_light_purple="\[\033[1;35m\]"
sh_brown="\[\033[0;33m\]"
sh_yellow="\[\033[1;33m\]"
sh_light_gray="\[\033[0;37m\]"
sh_white="\[\033[1;37m\]"

# TODO
HOSTCOLOUR=${sh_green}

function git_current_branch {
  git branch 2>/dev/null | awk '/^\* /{print $2 }'
}
function git_dirty {
  git st 2> /dev/null | grep -c : | awk '{if ($1 > 0) print "*"}'
}
function git_formatted_current_branch_with_dirty {
  if [ -n "$(git_current_branch)" ]; then
    echo " ($(git_current_branch)$(git_dirty))"
  fi
  #awk '{if ($(git_current_branch)) print " (" $(git_current_branch)$(git_dirty) ")"}'
}
function dollar_or_pound {
  if [ $(whoami) == "root" ]; then
    echo "#"
  else
    echo "$"
  fi
}
# bleh, el ugly :/
function git_status {
  if [ -n "$(git status 2>/dev/null)" ]; then
    #echo "$(git status 2>/dev/null)"
    echo "["
  else
    echo "["
  fi
}

function git_dirty_flag() {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "⚡"
  #git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) print "☠"}'
}

export PS1="${sh_yellow}[<\u@${HOSTCOLOUR}\h${sh_norm}${sh_yellow}>][\t][\w][${sh_red}\$(__git_ps1 '%s')${sh_yellow}]\n${sh_yellow}$ ${sh_norm}"

# }}}

# options {{{

# #stops ctrl+d from logging me out
set -o ignoreeof

# Turn on extended globbing and programmable completion
shopt -s extglob progcomp
# shell options
# extended globbing
shopt -s extglob
# allow .dotfile to be returned in path-name expansion
shopt -s dotglob
# this allows editing of multi-line commands.
shopt -s cmdhist
# make it append, rather than overwrite the history
shopt -s histappend
# fix typos
shopt -s cdspell
shopt -s histverify
shopt -s globstar
shopt -s autocd

# history settings
export HISTFILE=$HOME/.history/`date +%Y%m%d`.hist
export HISTSIZE=100000
export HISTCONTROL=erasedups

# browser
export BROWSER=/Applications/Firefox.app/Contents/MacOS/firefox-bin

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
$HOME/bin/binary/clic:\
"/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin":\
"$HOME/Applications/Graphics/Graphviz.app/Contents/MacOS":\
$HOME/work/tools/apache-maven-3.0/bin/:\
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
$PATH:$ROO_HOME/bin\
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
alias g?="grep -e $1"
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
alias psall='ps? NameNode DataNode TaskTracker JobTracker Quorum HMaster HRegion ThriftServer'

# }}}
