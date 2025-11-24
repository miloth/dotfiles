# Transient prompt hack for Starship
# https://github.com/starship/starship/issues/888#issuecomment-2239111488

set-long-prompt() { PROMPT=$(starship prompt) }
precmd_functions=(set-long-prompt)

set-short-prompt() {
  if [[ $PROMPT != '%# ' ]]; then
      PROMPT=$(starship module character)
    zle .reset-prompt
  fi
}

zle-line-finish() { set-short-prompt }
zle -N zle-line-finish

trap 'set-short-prompt; return 130' INT
