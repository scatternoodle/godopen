#!/usr/bin/env bash

set -euo pipefail

HELP_TEXT='Find and open your Godot Projects with Neovim instance with ease.

Usage: godopen [OPTIONS]

Options:
  -h, --help
      --project-dir <PATH>	Specify a project directory, instead of fuzzy finding. Overrides --entry-point.
  -e, --entry-point <PATH>	Use a specific starting directory for the search. Default is home directory.'

ENTRY_POINT="$HOME/workspace"
PROJECT_PATH=""


# find folders that contain a .godotproject file, pipe that to fzf in a purdy way
find_fuzzy() {
	local start_dir="$1"
	find "$start_dir" -type f -name "project.godot" -print0 | \
	xargs -0r -n1 dirname | \
	fzf 	--layout=reverse \
		--border=bold \
		--border-label=" Entrypoint: $ENTRY_POINT " \
		--border-label-pos=3 \
		--preview="lsd --all --classify --color always --icon always {}" \
		--preview-window=right:60%,border-double \
		--preview-label=" Godot Projects "
}

# Returns the value of the given flag, or exits with 1 if there is no value.
must_flag_value() {
	local flag_name="$1"
	shift

	if [[ $# -lt 1 || "$1" == -* ]]; then
		echo "Error: $flag_name must have a value" >&2
		echo "$HELP_TEXT" >&2
		exit 1
	fi
	echo "$1"
}

main() {
	while [[ "$#" -gt 0 ]]; do
		case "$1" in
			"-h"|--help)
				echo "$HELP_TEXT"
				exit 0
				;;
			--project-dir)
				PROJECT_PATH=$(must_flag_value "$@")
				shift
				shift
				;;
			"-e"|--entry-point)
				ENTRY_POINT=$(must_flag_value "$@")
				shift
				shift
				;;
			-*)
				echo "Error: unknown option $1" >&2
				echo "$HELP_TEXT"
				exit 1
				;;
			*)
				echo "Error: Unexpected argument $1" >&2
				echo "$HELP_TEXT"
				exit 1
				;;
		esac
	done

	if [[ -z "$PROJECT_PATH" ]]; then
		PROJECT_PATH=$(find_fuzzy "$ENTRY_POINT")
	fi

	# just in case... if the find_fuzzy call failed then we're probably exiting before this.
	if [[ -z "$PROJECT_PATH" ]]; then
		echo "No directory selected, exiting."
		exit 0
	fi
	echo "Project path selected: $PROJECT_PATH"

	local project_name=$(basename "$PROJECT_PATH")
	local tmux_session_name="godot_$project_name"
	echo "Checking if session $tmux_session_name exists..."
	if tmux has-session -t "$tmux_session_name" 2>/dev/null; then
		echo "Attaching to pre-existing tmux session: $tmux_session_name"
		tmux attach-session -t "$tmux_session_name"
		exit 0
	fi

	echo "Launching Godot and Neovim in a new tmux session."
	tmux new-session -d -s "$tmux_session_name" -c "$PROJECT_PATH"
	tmux send-keys -t "$tmux_session_name" "mkdir -p tmp && nohup godot --editor project.godot &> tmp/godot.log &" C-m
	sleep 1
	tmux send-keys -t "$tmux_session_name" "nvim" C-m
	tmux new-window -d -t "$tmux_session_name" -c "$PROJECT_PATH" -n "bash"
	echo "Attaching to session: $tmux_session_name"
	tmux attach-session -t "$tmux_session_name"
}

main "$@"
