#!/usr/bin/env zsh
# Short script to set up git signing related configuration properties and file that require public
# ssh keys.

signers_file=$HOME/.config/git_allowed_signers
tmp_signers_file=${signers_file}_tmp
if [[ -f $signers_file ]]; then
  mv -f $signers_file $tmp_signers_file
fi
usr=$(git config --get --global user.email)
ssh_key_file=$HOME/.ssh/id_rsa.pub
if [[ ! -f $ssh_key_file ]]
then
  if [[ -f $tmp_signers_file ]] then
    mv -f $tmp_signers_file $signers_file
  fi
fi
read -r ssh_key<$ssh_key_file
echo $usr $ssh_key > $signers_file
git config --global user.signingkey $ssh_key
git config --global gpg.ssh.allowedSignersFile $signers_file
