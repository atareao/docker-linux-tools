# Docker Linux Tools

This repository contains a Dockerfile to build a Linux image based on Alpine 3.23 with a set of useful tools for development and system administration.

## Tools Included

The image includes the following tools:

- `curl`: A command-line tool for transferring data with URLs.
- `bat`: A cat(1) clone with syntax highlighting and Git integration.
- `neovim`: A modern, highly extensible Vim-based text editor.
- `ripgrep`: A line-oriented search tool that recursively searches the current directory for a regex pattern.
- `fd`: A simple, fast and user-friendly alternative to 'find'.
- `sd`: An intuitive find and replace CLI.
- `rnr`: A command-line tool to rename files and directories.
- `lsd`: A modern ls command with a lot of pretty colors and awesome icons.
- `yazi`: A fast and lightweight terminal file manager.
- `starship`: A minimal, blazing-fast, and infinitely customizable prompt for any shell.
- `fish`: A smart and user-friendly command line shell.

## Build

To build the Docker image, run the following command in the root of the repository:

```bash
docker build -t linux-tools .
```

## Usage

To use the tools, you can run a container and get an interactive shell:

```bash
docker run -it --rm linux-tools sh
```
