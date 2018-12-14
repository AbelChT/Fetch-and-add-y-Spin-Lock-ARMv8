#!/bin/bash

#
# Script that launch all threads competitions
#
echo thread_competition_naive_mutex
./thread_competition_naive_mutex
echo

sleep 4

echo thread_competition_none_mutex
./thread_competition_none_mutex
echo

sleep 4

echo thread_competition_spin_lock
./thread_competition_spin_lock
echo

sleep 4

echo thread_competition_spin_lock_ee
./thread_competition_spin_lock_ee
echo

sleep 4

echo thread_competition_spin_lock_ee_b
./thread_competition_spin_lock_ee_b
echo

sleep 4

echo thread_competition_spin_lock_ee_b_ne
./thread_competition_spin_lock_ee_b_ne
echo

sleep 4

# Optimized versions
echo thread_competition_naive_mutex_o3
./thread_competition_naive_mutex_o3
echo

sleep 4

echo thread_competition_none_mutex_o3
./thread_competition_none_mutex_o3
echo

sleep 4

echo thread_competition_spin_lock_o3
./thread_competition_spin_lock_o3
echo

sleep 4

echo thread_competition_spin_lock_ee_o3
./thread_competition_spin_lock_ee_o3
echo

sleep 4

echo thread_competition_spin_lock_ee_b_o3
./thread_competition_spin_lock_ee_b_o3
echo

sleep 4

echo thread_competition_spin_lock_ee_b_ne_o3
./thread_competition_spin_lock_ee_b_ne_o3