#!/bin/bash

# this is prep step 
# download new daily cases file from covidtracking
# hopefully can be cron'ed like:
# cd ... ; ./fetchNewCaseDataFile.sh ; ./AlgC_state+capa+case+calc.sh
# this worked ok in USS, need some ndjson tool from npm install

#wget https://covidtracking.com/api/v1/states/daily.json   -O cases_daily_dw_2020_0419.json    # one version was checked into git
wget https://covidtracking.com/api/v1/states/daily.json   -O cases_daily_automaton.json 


# if all ok, then can invoke AlgC_state+capa+case+calc.sh


