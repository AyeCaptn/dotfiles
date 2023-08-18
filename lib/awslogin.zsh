function awslogin() {
    selected=$(aws configure list-profiles | fzf)
    aws-vault --debug login $selected --stdout | xargs -t /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --incognito --new-window
}
