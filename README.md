# Godopen
Easily open a specific Godot project with editor and Neovim from your terminal.

## Summary
Godopen is a lightweight CLI that allows you to open any Godot project root, launch Neovim and a Godot editor instance.

It can used interactively (with fuzzyfind) or with a specific project root passed as an argument. Godot project root directories are identified by the presense of a `project.godot` file.

This project is freely available to use, reference or copy. As this is a personal tool, I will not be supporting issues or feature requests. As this is under MIT license you may do as you wish with it, though if you post / distribute a version of this code elsewhere, attribution while not required would be appreciated :)

## Dependencies
The following programs are required to run this tool:
- [fzf](https://github.com/junegunn/fzf)
- [lsd](https://github.com/lsd-rs/lsd)
- [tmux](https://github.com/tmux/tmux/wiki)

`But isn't this awfully opinionated?` Yes. As mentioned, this is a personal tool designed for my own needs and tastes. Do feel free to fork / copy and adapt as you see fit.

## Installation
This tool is implemented in Bash, and only Linux is supported. WSL, MacOS, and BSD may work with adaptations but this has not been tested.

To install, simply clone down the repo, and move `godopen.sh` to wherever you like to keep your user installs.

## Usage


Usage: godopen \[OPTIONS\]

Options:
  -h, --help
      --project-dir \<PATH\>	Specify a project directory, instead of fuzzy finding. Overrides --entry-point.
  -e, --entry-point \<PATH\>	Use a specific starting directory for the search. Default is home directory.'
