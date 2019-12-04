#!/bin/bash

if [ -z "${1}" ]; then
    echo "Specify a directory to check"
    exit 1
fi

if [ "${2}" != "--skip-init-check" ]; then
    N_NF_JOBS=$(find ${1} -mindepth 1 -maxdepth 1 -type d '!' -exec test -e "{}/logs/" ';' -print | tee /dev/stderr | wc -l)
    if [ "${N_NF_JOBS}" -gt "0" ]; then
        echo "ERROR: ${N_NF_JOBS} did not run yet or failed to run."
    fi
fi

total_count=0
not_finished_jobs=0

for logfile in $(find ${1} -name "*.o*"); do
    ((total_count++))

    count=`grep -c "Step 07. Finished!" ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, not finished yet: ${logfile}"
        ((not_finished_jobs++))
        continue
    fi
done

echo "Finished checking ${total_count} logs:"
echo "  ${not_finished_jobs} did not finish yet"


echo "Checking download logs"
for logfile in $(find ${1} -name "*.e*"); do
    ((total_count++))

    count=`grep -c " 100% " ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, download not finished: ${logfile}"
        ((not_finished_jobs++))
        continue
    fi

    count=`grep -c " saved " ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, download not saved: ${logfile}"
        ((not_finished_jobs++))
        continue
    fi
done


total_count=0
if [ -d "${2}" ]; then
    for gwasfile in $(find ${2} -name "*.tsv.gz*"); do
        ((total_count++))

        filesize=`stat --printf="%s" ${gwasfile}`
        filesize=`expr $filesize / 1024 / 1024`

        if [ ${filesize} -lt 410 ]; then
            echo "WARNING, filesize incorrect (${filesize}) in file: ${gwasfile}"
            continue
        fi
    done
fi


exit 0

