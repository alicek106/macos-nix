function tf_prompt_info() {
    # dont show 'default' workspace in home dir
    [[ "$PWD" == ~ ]] && return
    # check if in terraform dir
    if [ -d .terraform ]; then
      if [ -f .terraform/environment ]; then
        workspace=$(cat .terraform/environment 2> /dev/null) || return
        echo "[${workspace}]"
      else
        echo "[default]"
      fi
    fi
}
