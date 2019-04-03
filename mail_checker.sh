#!/bin/bash

# TODO Write some regex that captures domain names in $HOME/mail

# Run find from $HOME so output looks like $HOME/etc/<stuff>
# find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc)\w+\.\w+)|\w+$)' | cut -d'/' -f5

# Actually try /var/cpanel/users/$user and /var/cpanel/userdata/$user
# awk -F'DNS[0-9]?=' ' NF > 1 {print $2}' /var/cpanel/users/$(whoam i)

# TODO Display all addresses for each domain found in $HOME/mail by checking shadow + passwd

for DOMAIN in $(find $HOME/etc/ -regextype posix-egrep -regex '(\/\w+){4}\.(((?!rc)\w+\.\w+)|\w+$)' | cut -d'/' -f5); do 
  for PASSWD_ADDRESS in $(awk -F':' '{print $1}' $HOME/etc/$DOMAIN/passwd); do
      for SHADOW_ADDRESS in $(awk -F':' '{print $1}' $HOME/etc/$DOMAIN/shadow); do
        [[ $PASSWD_ADDRESS == $SHADOW_ADDRESS ]] && \
        echo $DOMAIN - $PASSWD_ADDRESS
      done  
  done
done

# TODO Check for orphaned entries in shadow/passwd/mail

# TODO Display size (breakdown and total), quotas, mail count (per box and total)

# TODO Do MX check (IP , remote/local)

# TODO Check for forwarders, autoresponders, filters

# TODO Check for exim/dovecot logs if possible

# TODO Check for top recipients/senders

# TODO Check and warn for incorrect perms
