export FZF_BASE=$PREFIX/share/fzf
export FZF_DEFAULT_COMMAND="fd --no-ignore-vcs --exclude node_modules --exclude .git . ."
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d --no-ignore-vcs --exclude node_modules --exclude .git . ."

source $FZF_BASE/key-bindings.zsh
source $FZF_BASE/completion.zsh

fzf-global-file-widget() {
    tmp_ctrl_t=$FZF_CTRL_T_COMMAND
    FZF_CTRL_T_COMMAND="fd --no-ignore-vcs --exclude node_modules --exclude .git . /"
    fzf-file-widget
    FZF_CTRL_T_COMMAND=$tmp_ctrl_t
    unset tmp_ctrl_t
}
zle -N fzf-global-file-widget
bindkey '^G' fzf-global-file-widget
