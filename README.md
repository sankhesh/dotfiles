# DotFiles

Most of my configuration files in one location. I use [dotbot][dotbot] for
bootstrapping configuration files.

## Installation

After cloning this repository, run `install` to automatically set up the
development environment. Note that the script is idempotent: it can safely be
run multiple times.

The installer builds the local GPG agent config from `gnupg/gpg-agent.conf`,
retaining additional local options and backing up an existing config before
changing it. On macOS, it detects `pinentry-mac` in `PATH` and adds its path
as `pinentry-program`. The config is written to `$GNUPGHOME/gpg-agent.conf`,
or `~/.gnupg/gpg-agent.conf` when `GNUPGHOME` is unset.

## VIM setup

This setup assumes that VIM 7.0 or greater is installed on the system.
The install method mentioned [above](#Installation) would create symbolic links
for the following files in the user's HOME directory:

  * .vimrc
  * .vim

### YouCompleteMe plugin
The install also fetches the [YouCompleteMe][youcompleteme] git submodule. To
install YouCompleteMe, simply navigate to the YouCompleteMe folder and run the
`install.sh` script.

    cd ${HOME}/.vim/bundle/YouCompleteMe
    ./install.sh --clang-completer

### Bundles
I use [vundle][vundle] to manage plugins. To install the plugins, run:

    :BundleInstall
from within vim.


[dotbot]:https://github.com/anishathalye/dotbot
[youcompleteme]:https://github.com/Valloric/YouCompleteMe
[vundle]:https://github.com/gmarik/Vundle.vim
