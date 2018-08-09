alias cd='pushd . >> /dev/null;cd'
alias back='popd >> /dev/null'
alias ld='dirs -p | nl -v 0'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ll='pwd;ls -la'
alias g2='goto'
alias gd='go_deep'
alias gf='go_find'

b() {
  [ -z "$1" ] && local c=1 || local c=$1
  for ((i=1; i<=$c; i++))
  do
    back
  done
}

get_choice() {
  local count=`printf "$choice_set" | wc -l | awk '{print $1}'`
  [ ${#choice_set} -eq 0 ] || count=$((count+1))
  local re='^([0-9]+)$'
  if [ $count -eq 0 ]; then
    echo "No match found" && export choice_set=""
  elif [ $count -eq 1 ]; then
    export choice_set="$choice_set"
  else
    printf "$choice_set\n" | nl
    local s=0
    local p="p"
    while [ "$s" != "q" ] && ( ! [[ $s =~ $re ]] || ! [ $s -le $count -a $s -gt 0 ] )
    do
      if [[ "$s" =~ [a-zA-Z] ]]; then
        local filtered_choice_set=`printf "$choice_set" | grep -i ".*$s.*"`
        local filtered_count=`printf "$filtered_choice_set" | wc -l | awk '{print $1}'`
        [ ${#filtered_choice_set} -eq 0 ] || filtered_count=$((filtered_count+1))
        [ $filtered_count -gt 1 ] && choice_set="$filtered_choice_set" && count=$filtered_count && printf "$choice_set\n" | nl
        [ $filtered_count -eq 1 ] && choice_set="$filtered_choice_set" && return 0
      fi
      read s
    done
    [ "$s" != "q" ] && export choice_set="`printf \"$choice_set\" | sed -n $s$p 2>/dev/null`" || export choice_set=""
  fi
}

goto() {
  export choice_set=`ls -AF1 | grep "/" | grep -i ".*$1.*"`
  get_choice
  [ "$choice_set" != "" ] && cd "$choice_set"
}

go_deep() {
  export choice_set=`find . -type d | grep -i ".*$1.*"`
  get_choice $@
  [ "$choice_set" != "" ] && cd "$choice_set"
}

go_find() {
  export choice_set=`find . | grep -i ".*$1.*"`
  get_choice $1
  [ "$choice_set" != "" ] && ([ ! -z $2 ] && cd $(dirname "$choice_set") || eval "$2$choice_set$3")
}
