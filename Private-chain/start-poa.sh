#!/bin/bash

./geth 	--datadir "./database" --ipcdisable --networkid 12121 --syncmode "full" --cache 512 --port 30303 console
