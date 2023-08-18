ktx() {
    current="$(kubectl config current-context)"
    selected=$( (
        kubectl config view -o jsonpath="{.contexts[?(@.name != '${current}')].name}" |
            xargs -n 1
        echo "${current}"
    ) | fzf -0 -1 --tac -q "${1:-""}" --prompt "$current> ")
    if [ ! -z "$selected" ]; then
        kubectl config use-context "${selected}"
    fi
}
