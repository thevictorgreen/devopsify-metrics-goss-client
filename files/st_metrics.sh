#!/bin/bash

# LOG OUTPUT TO /var/log/smoke_test_metrics.out
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>/var/log/smoke_test_metrics.out 2>&1

# CHECK IF THE SMOKE TEST PROFILE EXISTS
if [[ ! -f "/usr/local/mcollect/profile.cfg" ]]
then
  # EXIT
  echo ${date} "smoke test profile does not exist: " date
  exit 0
else
  # GET ENVIRONMENT FROM /usr/local/mcollect/environment.cfg
  node_env=$(cat /usr/local/mcollect/environment.cfg)
  # CREATE SmokeTestID 1
  ts=$(date +%s)
  dufmt=$(date -d $ts 2>/dev/null | date '+%Y-%m-%d')
  dfmt=$(echo $dufmt | tr --delete -)
  # GET HOSTNAME
  node_name=$(hostname)
  # INITIALIZE SMOKE TEST NAME
  smt_name="BLANK"
  # INITIALIZE SMOKE TEST COMPONENT
  smt_component="BLANK"
  # INITIALIZE RUN STATUS
  run_status="BLANK"
  # GET CURRENT DATE AND TIMESTAMP
  #last_run=${ts}
  last_run=$(date +%Y-%m-%dT%TZ)
  # INITIALIZE GOSS DATA
  goss_data="BLANK"

  # READ SMOKE TEST PROFILE FROM /usr/local/mcollect/profile.cfg
  while IFS= read -r smoke_test
  do
    # CREATE SmokeTestID 2
    randomID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
    smt_id=${dfmt}-${randomID}
    # GET SMOKE TEST NAME
    smt_name=$(echo $smoke_test |cut -d '-' -f1)
    # GET SMOKE TEST COMPONENT
    smt_component=$(echo $smoke_test |cut -d '-' -f2)
    # RUN SMOKE TEST AND STORE RESULTS INTO GOSS DATA OBJECT
    goss_data=$( /usr/local/bin/goss -g /usr/local/mcollect/tests/${smoke_test}.yaml validate -f json )
    # WRITE GOSS DATA OBJECT TO A FILE TO PARSE
    echo ${goss_data} > /usr/local/mcollect/results.json
    # QUERY GOSS DATA OBJECT FOR FAIILED COUNT ATTRIBUTE
    failed_count=$( cat /usr/local/mcollect/results.json | jq '.summary["failed-count"]' )
    # CHECK VALUE OF FAILED COUNT
    # IF failed_count == 0 THEN run_status = SUCCEEDED
    # ELSE run_status = FAILED
    if [ $failed_count -eq 0 ]
    then
      run_status="SUCCEEDED"
    else
      run_status="FAILED"
    fi
    # BUILD SMOKE TEST RESULT OBJECT WITH ENRICHED METADATA AND WRITE TO LOG FILE
    echo '{"node_env":"'${node_env}'","smt_id":"'${smt_id}'","node_name":"'${node_name}'","smt_name":"'${smt_name}'","smt_component":"'${smt_component}'","run_status":"'${run_status}'","last_run":"'${last_run}'","goss_data":'$(echo $goss_data)'}'
  done < /usr/local/mcollect/profile.cfg
fi
