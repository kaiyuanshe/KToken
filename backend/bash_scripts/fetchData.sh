#!/bin/bash

# fetch original files
today=$(date +%F)
mkdir "$today" && cd "$today"
curl -s -o fetchUser.json https://raw.githubusercontent.com/AmbitionCX/TestToken/main/UserName.json
curl -s -o fetchPoint.log https://raw.githubusercontent.com/X-lab2017/open-digger/master/CONTRIBUTORS

# re-organize contributor points to json file
fpt=point.json
jq -n --arg value "$(date +%s)" '{"date":$value, "user":{}}' > "$fpt"

while IFS= read -r line; do
        username=$(echo $line | awk '{print ($1)}')
        point=$(echo $line | awk '{print ($2)}')
        if [[ -n "$point" ]]; then
                cat "$fpt" | jq --arg un "$username" --arg pt "$point" '.user += {($un): $pt}' > tmp.json && mv tmp.json "$fpt"
        fi
done < fetchPoint.log

