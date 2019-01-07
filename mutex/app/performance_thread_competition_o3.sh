#!/bin/bash

#
# Created by Abel Chils Trabanco
#

#
# Script that launch all threads competitions and obtain the averange performance
#

# File where metrics(averange) results will be stored 
RESULTS_FILE="./results_avg_o3.txt"

# File where all results will be stored in seconds
ALL_RESULTS_FILE_CSV="./results_o3.csv"

# Number of iterations
NUMBER_OF_ITERATIONS=10

# Seconds to sleep between iterations to decrease board temperature
TIME_TO_SLEEP_BETWEEN_ITERARIONS=4

# Files that you want to test
FILES_TO_TEST=(
    thread_competition_naive_mutex_o3 
    thread_competition_none_mutex_o3
    thread_competition_spin_lock_o3 
    thread_competition_spin_lock_ee_o3
    thread_competition_spin_lock_ee_b_o3 
    thread_competition_spin_lock_ee_b_ne_o3
)

# Store the averange performance results
declare -A performance_results_avg

# Empty ALL_RESULTS_FILE_CSV if exists and create if not
> $ALL_RESULTS_FILE_CSV

# Initialize the hash map and init ALL_RESULTS_FILE_CSV
for application in ${FILES_TO_TEST[*]}
do
    performance_results_avg[$application]=0
    echo -n "$application;" >> $ALL_RESULTS_FILE_CSV
done

# Prepare to write results
echo >> $ALL_RESULTS_FILE_CSV

# Execute the applications to get the metrics
for i in $(seq 1 $NUMBER_OF_ITERATIONS)
do
    echo "---------------- Iteration $i of $NUMBER_OF_ITERATIONS ----------------" 

	for application in ${FILES_TO_TEST[*]}
    do
        echo "Executing $application"
        iteration_result=$("./$application")
        echo -n "$iteration_result;" >> $ALL_RESULTS_FILE_CSV
        # Utility bc is not installed so we need to use awk
        performance_results_avg[$application]=$(echo - | awk "{print ${performance_results_avg[$application]} + $iteration_result}")
        # performance_results_avg[$application]=$(echo "${performance_results_avg[$application]} + $iteration_result" | bc)
        sleep $TIME_TO_SLEEP_BETWEEN_ITERARIONS
    done

    # Prepare to write next results
    echo >> $ALL_RESULTS_FILE_CSV

    echo
done

# Init RESULTS_FILE
echo "Test done on" > $RESULTS_FILE
date >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Write averange to RESULTS_FILE
echo "Averange execution time (seconds)" >> $RESULTS_FILE
for application in ${FILES_TO_TEST[*]}
do
    actual_performance=$(echo - | awk "{print ${performance_results_avg[$application]} / $NUMBER_OF_ITERATIONS}")
    echo "$application: $actual_performance" >> $RESULTS_FILE
done