if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish | source
end

abbr dir eza -l --hyperlink --group-directories-first
abbr z sudo zypperoni
abbr dup 'sudo zypperoni ref && sudo zypper dup'
abbr h 'hledger -f ~/pCloud_local/PTA/daily.journal'
abbr pta 'cd ~/pCloud_local/PTA/'
abbr nnn 'nnn -P p -d'

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
