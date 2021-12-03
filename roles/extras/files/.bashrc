#Get current k8s context
context(){
  current_context=$(kubectl config current-context 2> /dev/null)
  if [[ $? -eq 0 ]] ; then echo -e " k8s:${current_context}"; fi
}

#Get current git branch
branch() { 
  current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ $? -eq 0 ]] ; then echo -e " git:${current_branch}"; fi
}

#Set coloured dirs and folders first
export LS_OPTIONS='--color=auto --group-directories-first'
eval "$(dircolors -b)"

#Set aliases
alias ls='ls $LS_OPTIONS'
alias ll='ls -alF'
alias kc='k3d cluster create dev  -p 80:80@loadbalancer -p 443:443@loadbalancer --k3s-arg "--disable=traefik@server:0" --volume /etc/hosts:/etc/hosts'
alias kd='k3d cluster delete dev'
alias ku='wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash'

#Set bash history settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:ignorespace

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#Set autocomplete using up/down
if [[ $- == *i* ]]
then
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'
fi

#Set bash prompt
if [ $(id -u) -eq 0 ];
then
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(context)\$(branch)\n\[\033[00m\]# "
else 
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(context)\$(branch)\n\[\033[00m\]$ "
fi
