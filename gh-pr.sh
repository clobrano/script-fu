#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script is a wrapper around GitHub CLI (gh) "pr" subcommand.
## Thanks to https://github.com/cli/cli/issues/6089#issuecomment-1220250908

# .zshrc gh pr list command extended with fzf, see the man page (man fzf) for an explanation of the arguments.
[[ ! "$(git rev-parse --is-inside-work-tree)" ]] && return 1
GH_COMMAND='gh pr list --state open --json number,author,headRefName,additions,deletions,updatedAt,title --template "
{{- tablerow (\"PR\" | color \"blue+b\") (\"LAST UPDATE\" | color \"blue+b\") (\"AUTHOR\" | color \"blue+b\") (\"BRANCH\" | color \"blue+b\") \"\" \"\" (\"TITLE\" | color \"blue+b\") -}}
{{- range . -}}
    {{- tablerow (printf \"#%v\" .number | color \"green+h\") (timeago .updatedAt | color \"gray+h\") (.author.login | color \"cyan+h\") (.headRefName | color \"cyan+h\") (printf \"+%v\" .additions | color \"green\") (printf \"-%v\" .deletions | color \"red\") .title -}}
{{- end -}}" --search'
FZF_DEFAULT_COMMAND="$GH_COMMAND ${1:-\"\"}" \
    GH_FORCE_TTY=100% fzf --ansi --disabled --no-multi --header-lines=1 \
    --header $'CTRL+W - Browser | CTRL+D - Toggle Diff  | CTRL+Y - Comment\nCTRL+I - Toggle Info  | Enter - Checkout' \
    --prompt 'Search Open PRs >' --preview-window hidden:wrap \
    --layout=reverse --info=inline --no-multi \
    --bind "change:reload:sleep 0.25; $GH_COMMAND {q} || true" \
    --bind 'ctrl-w:execute-silent(gh pr view {1} --web)' \
    --bind 'ctrl-d:toggle-preview+change-preview(gh pr diff {1} --color always)' \
    --bind 'ctrl-i:toggle-preview+change-preview(gh pr view {1} --comments)' \
    --bind 'ctrl-y:accept+execute(gh pr comment {1})' \
    --bind 'enter:accept+execute(gh pr checkout {1})'
