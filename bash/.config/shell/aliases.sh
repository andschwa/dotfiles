# Emacs as editor
alias __emacsclient='emacsclient --alternate-editor="" --no-wait'
# Create a new frame
alias e='__emacsclient --create-frame'
# Or reuse an existing frame
alias er='__emacsclient'
# Or open in the terminal
alias et='__emacsclient --tty'

# create a frame when programs invoke the editor
export VISUAL=e EDITOR=e

# p: a common package manager interface
source ~/.config/shell/packages.sh

# miscellaneous
alias sudo='sudo ' # enable alias expansion for sudo
alias g='git'
complete -o default -o nospace -F _git g
alias make='make --debug=b'
alias ping='ping -c 8'
alias root='sudo su'
alias cppc='cppcheck --std=c++11 --enable=all --suppress=missingIncludeSystem .'
alias octave='octave --quiet'
if command -v thefuck >/dev/null 2>&1; then
    eval "$(thefuck --alias)"
fi
