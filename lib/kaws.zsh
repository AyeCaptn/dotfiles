kaws() {
    selected=$(aws configure list-profiles | fzf)
    export AWS_PROFILE=$selected
}
