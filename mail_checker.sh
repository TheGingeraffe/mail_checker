#!/bin/bash

## Arrays ##

declare -A domain_info

## Functions ##

# Prints a list of domains present in $HOME/mail

get_domains(){
  find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc )\w+\.\w+)|\w+$)' \
  | cut -d'/' -f5
}

# Prints a list of addresses present in $HOME/mail

get_addresses(){
  find $HOME/mail/*/ -maxdepth 1 -regextype posix-egrep  -regex '(\/\w+){4}\.\w+\/\S+' \
  | awk 'BEGIN {FS="/"; OFS="@"} {print $6, $5}'
}

# Prints DNS info with trailing "." trimmed
# get_mx $domain $record

get_dns(){
  dig +nocmd $1 $2 +multiline +noall +answer | sed -r 's/\.(\s|$)/ /g'
}

# TODO make this output nicer
# Grabs and prints sizes

get_size(){
        du -sh $HOME/mail/$1/$2;
}

# Runs some checks on addresses in shadow and passwd for a given domain
# hash_checker domain (passwd|shadow) (passwd|shadow)
# TODO add perm checking to these 2 files

hash_checker(){
  for address in $(awk -F':' '{print $1}' $HOME/etc/$1/$2); do
    if grep -q $address $HOME/etc/$domain/$3 && \
    [[ -e $HOME/mail/$1/$address ]]; then
      continue
    else
      echo -e "\n$address@$domain may have issues. Check that"\
      "address exists in $HOME/mail/${1}, has entries in"\
      "$HOME/etc/$1/{shadow,passwd}, and that permissions are correct."
    fi
  done
}

# TODO find a way to look in passwd, shadow, and maildir for addresses in this list (to capture max addresses)
# TODO find a way to capture domain list from /var/cpanel/userdata/$(whoami)/main

# Iterates through output of get_addresses and pairs address names with 
# their domain in the domain_info array

for i in $(get_addresses); do
  address="$(echo $i | cut -d'@' -f1)"
  domain="$( echo $i | cut -d'@' -f2)"
  domain_info[$domain]+="$address "
done

# Prints addresses in $HOME/mail under each domain

for domain in "${!domain_info[@]}"; do
  echo -e "\nThese addresses are present in ${HOME}/mail/${domain}:"
  echo
  for address in $(echo "${domain_info[$domain]}"); do
    echo "${address}@${domain}"
  done
done

# Iterates through domains and performs shadow/passwd file checks

for domain in "${!domain_info[@]}"; do
  if [[ -e $HOME/etc/$domain/passwd ]] && \
  [[ -e $HOME/etc/$domain/shadow ]]; then
    hash_checker $domain shadow passwd
    hash_checker $domain passwd shadow
  else
    echo -e "\nThere is something wrong with the shadow/passwd files for ${domain}." \
    "Check that they exist and that permissions are correct.\n"
  fi
done

# TODO add uapi loop that recreates addresses if user says "yes" for each domain

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

# TODO quotas

# TODO mail count for address + each box, inbox/sent/trash 

# TODO du breakdown of each mailbox


# TODO Check for forwarders
# Forwarders and autoresponders are found in /etc/valiases/${domain}
# TODO Check for autoresponders

# TODO Check for filters
# Filters are found in /etc/vfilters/${domain}

# Checks and prints NS + MX info for domains in array
# Find authoritative NS from WHOIS, do a cURL to workaround broke whois command (segfault on shared)

for domain in "${!domain_info[@]}"; do
  echo -e "DNS checks for ${domain}:\n"
  get_dns $domain ns
  echo
  get_dns $domain mx
  echo
done

# TODO Check remote/local (maybe not possible?)

# TODO SPF

# TODO DKIM

# Ask for DKIM selector when run, or just assume default?
# Possible selectors: default, google, dkim
# Search through mail headers for dkim?

# TODO DMARC

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders
# Some Regex that captures 5, 10 of each? for 24 hours?

# TODO Check and warn for incorrect perms
# Probably just chmod 777 ~/mail/* && chown $USER.somebody ~/mail/* and then capture output of permfix
