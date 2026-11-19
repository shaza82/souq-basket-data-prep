# Souq Basket - review data preparation

Souq Basket is an online store. This project takes the raw customer-review
file and the raw server log and turns them into clean files and small
reports that the data team can use. Everything is done with plain
Linux terminal commands (no Python, sed, awk or Excel).

## Folder layout

    souq-basket-data-prep/
      raw/       the original files - never changed (read-only)
      clean/     cleaned review files made by the script
      reports/   small text reports (counts, log summary, permissions...)
      scripts/   prepare_data.sh - repeats the whole preparation in one go
      README.md  this file

## How to run

    chmod +x scripts/prepare_data.sh
    ./scripts/prepare_data.sh

You can run it as many times as you like. It only reads from raw/ and
rewrites clean/ and reports/, so the result is always the same.

## What the script does

1. Inspects reviews_raw.csv (first and last 5 lines, line count, header count).
2. Builds clean/reviews_clean.csv: one header, no empty lines, no duplicates.
3. Counts reviews per rating and per category.
4. Saves the 1-star and 2-star reviews to clean/low_rating_reviews.csv.
5. Counts the reviews that mention "late delivery".
6. Summarises app_server.log: number of ERROR lines, WARN lines and the
   five most common error messages.

## Where things live on a Linux server (what the main folders are for)

- /home - personal folders of the users (for example /home/analyst).
  Work files that belong to one person go here.
- /etc - configuration files of the system and of installed programs
  (users, groups, network settings...). Normally only the admin edits it.
- /var/log - log files written by the system and by services
  (for example our app_server.log is the kind of file kept here).
- /tmp - temporary scratch space. Anything here may be deleted at any
  time or when the machine restarts, so never keep important data in /tmp.

## Note about raw/

The two starter files (reviews_raw.csv and app_server.log) are course
material and are **not stored in this repository**. To run the script,
copy them into a folder called raw/ next to scripts/ first.
