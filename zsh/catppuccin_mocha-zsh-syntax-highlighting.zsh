# Catppuccin Mocha Theme (for zsh-syntax-highlighting)
#
# Paste this files contents inside your ~/.zshrc before you activate zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES

# Main highlighter styling: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
#
## General
### Diffs
### Markup
## Classes
## Comments
ZSH_HIGHLIGHT_STYLES[comment]='fg=#585b70'
## Constants
## Entitites
## Functions/methods
ZSH_HIGHLIGHT_STYLES[alias]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[function]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[command]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#4eba65,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#d77757,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#d77757'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#d77757'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#af87ff'
## Keywords
## Built ins
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#4eba65'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#4eba65'
## Punctuation
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#ff6b80'
## Serializable / Configuration Languages
## Storage
## Strings
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#ffc107'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#ffc107'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffc107'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffc107'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#ffc107'
## Variables
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#cdd6f4'
## No category relevant in spec
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#ff6b80,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#cdd6f4,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#ff6b80,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#af87ff'
#ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=?'
#ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]='fg=?'
#ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=?'
#ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=?'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#ff6b80'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=#cdd6f4'
