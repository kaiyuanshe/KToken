#!/bin/bash

today=$(date +%F)
cd "$today"

diff=difference.json
if [[ $(jq -r '.date' account.json) -lt $(jq -r '.date' point.json) ]]; then echo "wrong"; fi
jq -n --arg value "$(date +%s)" --arg key date --arg p update '{($key):$value, ($p):[]}' > "$diff"

declare -a uname=($(jq -r '.user | keys_unsorted[]' account.json))
for name in "${uname[@]}"; do
        account=$(jq -r --arg k "$name" '.user | "\(.[$k].account)"' account.json)
        if [[ $account == "null" ]]; then continue; fi
        pt_onchain=$(jq -r --arg k "$name" '.user | "\(.[$k].balance)"' account.json)
        if [[ $pt_onchain == "invalid account" ]]; then continue; fi
        pt_update=$(jq -r --arg k "$name" '.user | "\(.[$k])"' point.json)

        if [ $pt_onchain -lt $pt_update ]; then
                action="plus"
                value=$(($pt_update - $pt_onchain))
        elif [ $pt_onchain -gt $pt_update ]; then
                action="minus"
                value=$(($pt_onchain - $pt_update))
        fi
        cat "$diff" | jq --arg a "$account" --arg b "$action" --arg val "$value" '.update += [{"account": $a, "action": $b, "value": $val}]' > tmp.json && mv tmp.json "$diff"
done

