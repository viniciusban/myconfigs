# vim: filetype=sh
#
# Set environment for bash.
#
# Open "ps1_hostname_alias.example" and "ps1_colors.example" for examples of
# prompt customization.
#
# Open "pyenv_global_command.example" file for example of pyenv global command.


__aliases () {
    alias ..='cd ..'
    alias .2='cd ../..'
    alias .3='cd ../../..'

    alias l='ls -lhgo'
    alias ll='ls -lh'
    [[ "${OSNAME}" = "Darwin" ]] && alias ls='ls -Gp'
    [[ "${OSNAME}" = "Linux" ]] && alias ls='ls -p --group-directories-first --color=auto'

    alias ack='ack --sort-files --color-filename="bold blue" --color-lineno="blue" --color-match="bold white on_blue" --ignore-dir=is:.venv --ignore-dir=is:.vagrant --ignore-file=ext:sqlite3'
    alias grep='grep --color=auto'

    alias now='date -u +%y%m%d%H%M'

    # one-letters
    alias j='jupyter notebook --no-browser --ip=localhost.test --NotebookApp.allow_remote_access=True'
}


__start_wsl_services () {
    __start_ssh_agent
}


__start_ssh_agent () {
    if [[ -n "$SSH_AGENT_PID" ]]; then
        current_agent=$(pgrep -f ssh-agent)
        if [[ "$current_agent" = "$SSH_AGENT_PID" ]]; then
            return
        fi
    fi

    source_file=/tmp/ssh-agent-source-file
    if [[ -f "$source_file" ]]; then
        source $source_file >/dev/null 2>&1
        current_agent=$(pgrep -f ssh-agent)
        if [[ "$current_agent" = "$SSH_AGENT_PID" ]]; then
            return
        fi
    fi

    ssh-agent -s >$source_file
    source $source_file >/dev/null 2>&1
}


__variables () {
    [[ -z "${OSNAME}" ]] && export OSNAME="$(uname)"
    [[ -z "$TMPDIR" ]] && export TMPDIR=/tmp
    export HISTCONTROL=ignoreboth
    export HISTTIMEFORMAT="%F %T "
    export EDITOR=$(which nvim || which vim)
    export VISUAL=$EDITOR

    # Custom hostname in prompt. See "ps1_hostname_alias.example" file.
    [[ -r ~/.ps1_hostname_alias ]] && source ~/.ps1_hostname_alias

    # Custom color prompt. See "ps1_colors.example" file.
    export PS1_COLOR_RESET="\[\033[m\]"
    [[ -r ~/.ps1_colors ]] && source ~/.ps1_colors

    export PS1="${PS1_COLOR_RESET}${PS1_COLOR_ERROR}\$(VALU=\$? ; [ \$VALU -ne 0 ] && echo ' '\${VALU}' ')${PS1_COLOR_DEFAULT}@\${HOSTNAME_ALIAS:-\${HOSTNAME}} \${VIRTUAL_ENV:+${PS1_COLOR_VIRTUALENV}(}\W \$(__ps1_git ; echo \${PS1_GIT:+on \${PS1_GIT}}\${VIRTUAL_ENV:+)}) \$${PS1_COLOR_RESET} "

    [[ -n "$WSL_DISTRO_NAME" ]] && export DISPLAY=$(grep '^nameserver' /etc/resolv.conf | cut -d ' ' -f2):0.0
    [[ "${OSNAME}" = "Darwin" ]] && export LC_CTYPE=en_US.UTF-8 # Default UTF-8 makes python crash


    # # linuxbrew
    # if [[ -r /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    #   eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    # fi

    # pyenv
    if [[ -d ~/.local/bin/pyenv ]]; then
        export PYENV_ROOT=~/.local/bin/pyenv
        export PATH="$PYENV_ROOT/bin:$PATH"

        if which pyenv > /dev/null
        then
            eval "$(pyenv init -)"
            # Custom python versions. See "pyenv_global_command.example" file.
            [[ -r ~/.pyenv_global_command ]] && source ~/.pyenv_global_command
        fi
    fi

    # asdf-vm
    if [[ -d ~/.asdf ]]; then
        source $HOME/.asdf/asdf.sh
        source $HOME/.asdf/completions/asdf.bash
    fi
}


__ps1_git () {
    # Show git branch and indicators about status:
    #   - "+" means there are staged changes
    #   - "!" means there are unstaged changes

    # The main concern here is performance. So, I return as soon as
    # possible, cache last execution, avoid calling external processes like
    # grep, sed, etc. and abuse of bash expressions and logic.

    PS1_GIT_STATUS_OUTPUT=$(git status -b --porcelain=2 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        # Not a git repo
        PS1_GIT=
        return
    fi

    if [[ "${PS1_GIT_STATUS_OUTPUT}" = "${CACHED_PS1_GIT_STATUS_OUTPUT}" ]]; then
        # Nothing changed since previous prompt. Reuse current $PS1_GIT.
        return
    fi

    CACHED_PS1_GIT_STATUS_OUTPUT="${PS1_GIT_STATUS_OUTPUT}"

    local branch staged_indicator unstaged_indicator
    local rectype field1 field2 other_fields
    local branch_header="#"
    local untracked_item="?"
    local changed_item="1"
    local renamed_item="2"
    local unmerged_item="u"
    while read rectype field1 field2 other_fields; do
        if [[ -n "${staged_indicator}" && -n "${unstaged_indicator}" ]]; then
            # Indicator are already set. There's nothing more to look for.
            break
        fi
        if [[ -z "${branch}" && "${rectype}" = "${branch_header}" && "${field1}" = "branch.head" ]]; then
            local branch="${field2}"
            continue
        fi

        if [[ "${untracked_item}${unmerged_item}" =~ "${rectype}" ]]; then
            local unstaged_indicator="!"
            continue
        fi

        if [[ "${changed_item}${renamed_item}" =~ "${rectype}" ]]; then
            if [[ "${field1:0:1}" != "." ]]; then
                local staged_indicator="+"
            fi
            if [[ "${field1:1:1}" != "." ]]; then
                local unstaged_indicator="!"
            fi
            continue
        fi
    done <<< "${PS1_GIT_STATUS_OUTPUT}"

    PS1_GIT="${branch}${staged_indicator}${unstaged_indicator}"
}


__main () {
    set -o vi
    __variables
    __aliases
    [[ -n "$WSL_DISTRO_NAME" ]] && __start_wsl_services
}

__main

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
