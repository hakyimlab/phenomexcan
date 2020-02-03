#!/bin/bash

if [ -z "${1}" ]; then
    echo "Specify a directory to check"
    exit 1
fi

if [ -z "${2}" ]; then
    PATTERN="*"
else
    PATTERN="$2"
fi
echo "Pattern used ${PATTERN}"

total_count=0
not_finished_jobs=0
finished_with_error_jobs=0

for logfile in $(find ${1} -name "${PATTERN}.o*"); do
    ((total_count++))

    count=`grep -c "Exit Code:         0" ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, finished with error: ${logfile}"
        ((finished_with_error_jobs++))
        continue
    fi

    count=`grep -c "^done$" ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, not finished yet: ${logfile}"
        ((not_finished_jobs++))
        continue
    fi
done


echo "Finished checking ${total_count} logs:"
echo "  ${not_finished_jobs} did not finish yet"


echo "Checking error logs"
for logfile in $(find ${1} -name "${PATTERN}.e*"); do

    count=`grep -c "Computing colocalization probabilities" ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, not finished: ${logfile}"
        continue
    fi
done

exit 0

