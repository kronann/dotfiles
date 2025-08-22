#!/bin/bash

# Vérifier si on est dans le scratchpad
current_workspace=$(hyprctl activeworkspace -j | jq -r '.name')

if [[ "$current_workspace" == "special" ]]; then
    # Si on est dans le scratchpad, revenir au workspace précédent
    hyprctl dispatch workspace previous
else
    # Sinon, envoyer la fenêtre au scratchpad
    hyprctl dispatch movetoworkspace special
fi
