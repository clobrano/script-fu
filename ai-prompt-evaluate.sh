#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eu

DST="$HOME/.gemini/commands"
CSV="$DST/ai-prompt-scores.csv"

prompt=$1

# Get human evaluation inputs via GUI
result=$(zenity --forms --title="Human Evaluation" \
    --text="Rate the AI response (0-3 scale)" \
    --add-entry="Coherence" \
    --add-entry="Fabrication" \
    --add-entry="Completeness" \
    --add-entry="Comment (optional)" \
    --separator="|" 2>/dev/null)

if [ -z "$result" ]; then
    echo "Evaluation cancelled"
    exit 1
fi

h_coherence=$(echo "$result" | cut -d'|' -f1)
h_fabrication=$(echo "$result" | cut -d'|' -f2)
h_completeness=$(echo "$result" | cut -d'|' -f3)
comment=$(echo "$result" | cut -d'|' -f4)

version=$(git -C "$DST" rev-parse --short HEAD)
version_date=$(git -C "$DST" log -1 --format=%ci)

if [ ! -f "$CSV" ]; then
    echo "PROMPT; VERSION; VER-DATE; AI_COHERENCE; AI_FABRICATION; AI_COMPLETENESS; H_COHERENCE; H_FABRICATION; H_COMPLETENESS; COMMENT;" > "$CSV"
fi

echo "$prompt; $version; $version_date; -1; -1; -1; $h_coherence; $h_fabrication; $h_completeness; $comment;" >> "$CSV"
echo "evaluation done"
