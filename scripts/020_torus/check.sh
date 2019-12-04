#!/bin/bash

if [ -z "${1}" ]; then
    echo "Specify a directory to check"
    exit 1
fi

total_count=0
not_finished_jobs=0
finished_with_error_jobs=0

for logfile in $(find ${1} -name "*.o*"); do
    ((total_count++))

    count=`grep -c "Exit Code:         0" ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, finished with error: ${logfile}"
        ((finished_with_error_jobs++))
        continue
    fi

    count=`grep -c "Finished" ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, not finished yet: ${logfile}"
        ((not_finished_jobs++))
        continue
    fi
done

echo "Finished checking ${total_count} logs:"
echo "  ${not_finished_jobs} did not finish yet"


echo "Checking error logs"
for logfile in $(find ${1} -name "*.e*"); do
    ((total_count++))

    count=`grep -c " saved " ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, not downloaded/saved: ${logfile}"
        ((not_finished_jobs++))
        continue
    fi

    count=`grep -c "Output PIPs to file " ${logfile}`
    if [ "${count}" -ne "1" ]; then
        echo "WARNING, torus not finished?: ${logfile}"
        continue
    fi
done


total_count=0
if [ -d "${2}" ]; then
    for gwasfile in $(find ${2} -name "*.tsv.gz"); do
        ((total_count++))

        filesize=`stat --printf="%s" ${gwasfile}`
        filesize=`expr $filesize / 1024 / 1024`

        if [ ${filesize} -lt 50 ]; then
            echo "WARNING, filesize incorrect (${filesize}) in file: ${gwasfile}"
            continue
        fi
    done
fi


exit 0

