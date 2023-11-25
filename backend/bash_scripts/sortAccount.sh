#!/bin/bash

today=$(date +%F)
cd "$today"

uname=account.json
jq -n --arg value "$(date +%s)" --arg key date --arg uname user '{($key):$value, ($uname):{}}' > "$uname"

declare -a user_pnt=($(jq -r '.user | keys_unsorted[]' point.json))
declare -a user_acc=($(jq -r '. | keys_unsorted[]' fetchUser.json))
for name in "${user_pnt[@]}"; do
        if [[ $name =~ "[bot]"|"-bot" ]]; then continue; fi
        account="null"
        balance="0"
        if [[ "${user_acc[@]}" =~ "${name}" ]]; then
                account=$(jq -r --arg k "$name" '. | "\(.[$k])"' fetchUser.json)
                if [[ ${#account} -eq 42 ]] && [[ $account == 0x* ]]; then
                        #balance=$(/usr/bin/node ../get-balance.js "$account")
                        balance=90
                fi
        fi
        cat "$uname" | jq --arg name "$name" --arg acco "$account" --arg bala "$balance" '.user += {($name): {"account": $acco,"balance": $bala}}' > tmp.json && mv tmp.json "$uname"
done

