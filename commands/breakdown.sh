#!/bin/bash

# Total size of each domain

echo -e "\nTotal mail size by domain:\n"

for domain in "${!domain_info[@]}"; do
  echo "$(get_size $domain)"
done

# Total size of each address in $HOME/mail

echo -e "\nTotal mail size by address:\n"

for domain in "${!domain_info[@]}"; do
  for address in $(echo "${domain_info[$domain]}"); do
    echo "${address}@${domain} - $(get_size $domain $address)"
  done
  echo
done

# TODO du breakdown of each mailbox

# TODO mail count for address + each box, inbox/sent/trash

# TODO quotas
