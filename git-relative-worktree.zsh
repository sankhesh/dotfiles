#!/usr/bin/env zsh

# Script to convert absolute paths in git worktree configurations for gitdir to relative paths.
# This is particularly useful for the case where the worktree was created in WSL with a mapped
# drive. The absolute gitdir paths would not work with native Windows applications like Vim, etc.

# Usage:
# 1. Create a git-worktree with either WSL or Git Bash or Git-For-Windows in cmd.
# 2. Invoke git-relative-worktree
#     `git-relative-worktree <main-directory> <worktree>

function echoerr() {
  echo "ERROR: $@" 1>&2;
}

for x in $1 $2; do
  if [ ! -d "$x" ]; then
    echoerr "Not a valid directory: $x";
    exit 1
  fi
done

if [ ! -d "$1/.git" ]; then
  echoerr "Could not find directory named '$1/.git/'"
  exit 1
fi

if [ ! -f "$2/.git" ]; then
  echoerr "Could not find file named '$2/.git'"
  exit 1
fi

abs1=`realpath $1`
abs2=`realpath $2`
relp=`realpath --relative-to=$abs2 $abs1`

for line in "${(@f)"$(<$abs2/.git)"}"; do
  echo "Replacing '$abs1' with '$relp' in '$abs2/.git'"
  echo ${line//$abs1/$relp} >! "$abs2/.git"
done

bname=`basename $abs2`
gitwdir="$abs1/.git/worktrees/$bname"
gitwgitdir="$gitwdir/gitdir"
if [ ! -f "$gitwgitdir" ]; then
  echoerr "Could not find file '$gitwgitdir'"
  exit 1
fi
revrelp=`realpath --relative-to="$gitwdir" "$abs2"`
for line in "${(@f)"$(<$gitwgitdir)"}"; do
  echo "Replacing '$abs2' with '$revrelp' in '$gitwgitdir'"
  echo ${line//$abs2/$revrelp} >! "$gitwgitdir"
done

