function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source
if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
end

alias pamcan pacman
alias ls 'eza --icons'
alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias q 'qs -c ii'


# Configuration nnn
set -gx NNN_PLUG "v:imgprev;i:preview-tui"
set -gx NNN_FIFO "/tmp/nnn.fifo"
set -gx SPLIT "v"  # Split vertical pour preview
set -gx VISUAL micro
set -gx EDITOR micro

# Fonction nnn avec cd
function nnn
    # Block nesting of nnn in subshells
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo "nnn is already running"
        return
    end

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    set -x NNN_TMPFILE ~/.config/nnn/.lastd

    # Run nnn
    command nnn -P i $argv

    # cd on quit
    if test -e $NNN_TMPFILE
        source $NNN_TMPFILE
        rm $NNN_TMPFILE
    end
end
# Variables pour imgpreview avec Kitty
set -gx NNN_TERMINAL "kitty"
set -gx GUI 1


# function fish_prompt
#   set_color cyan; echo (pwd)
#   set_color green; echo '> '
# end
