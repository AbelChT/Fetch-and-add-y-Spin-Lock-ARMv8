#!/bin/bash

#
# Script that launch all threads competitions
#
echo thread_competition_naive_mutex
./thread_competition_naive_mutex
echo

echo thread_competition_none_mutex
./thread_competition_none_mutex
echo

echo thread_competition_spin_lock
./thread_competition_spin_lock
echo

echo thread_competition_spin_lock_ee
./thread_competition_spin_lock_ee
echo

echo thread_competition_spin_lock_ee_b
./thread_competition_spin_lock_ee_b
echo

# Optimized versions
echo thread_competition_naive_mutex_o3
./thread_competition_naive_mutex_o3
echo

echo thread_competition_none_mutex_o3
./thread_competition_none_mutex_o3
echo

echo thread_competition_spin_lock_o3
./thread_competition_spin_lock_o3
echo

echo thread_competition_spin_lock_ee_o3
./thread_competition_spin_lock_ee_o3
echo

echo thread_competition_spin_lock_ee_o3_b
./thread_competition_spin_lock_ee_o3_b