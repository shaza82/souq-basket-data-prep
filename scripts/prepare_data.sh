#!/usr/bin/env bash
# Souq Basket - prepare the review data and summarise the server log.
# Re-runnable: it only READS raw/ and REWRITES clean/ and reports/.
set -euo pipefail
cd "$(dirname "$0")/.."          # always work from the project root

RAW_CSV=raw/reviews_raw.csv
RAW_LOG=raw/app_server.log
CLEAN=clean/reviews_clean.csv
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

mkdir -p clean reports

# --- 2. Inspect the raw reviews file --------------------------------------
head -n 5 "$RAW_CSV" | tr -d '\r' > reports/inspection.txt
tail -n 5 "$RAW_CSV" | tr -d '\r' >> reports/inspection.txt
wc -l "$RAW_CSV" >> reports/inspection.txt
grep -c '^review_id' "$RAW_CSV" >> reports/inspection.txt

# --- 3. Clean: one header, no empty lines, no duplicates ------------------
tr -d '\r' < "$RAW_CSV" | grep -v '^[[:space:]]*$' > "$TMP"
head -n 1 "$TMP" > "$CLEAN"
tail -n +2 "$TMP" | grep -v '^review_id,' | LC_ALL=C sort -u >> "$CLEAN"
echo "clean row count (header + data): $(wc -l < "$CLEAN")" >> reports/inspection.txt

# --- 4. Reviews per rating (column 6) and per category (column 4) ---------
tail -n +2 "$CLEAN" | cut -d, -f6 | sort | uniq -c | sort -rn > reports/reviews_per_rating.txt
tail -n +2 "$CLEAN" | cut -d, -f4 | sort | uniq -c | sort -rn > reports/reviews_per_category.txt

# --- 5. 1-star and 2-star reviews (+ header) and the late-delivery count --
head -n 1 "$CLEAN" > clean/low_rating_reviews.csv
grep -E '^[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[12],' "$CLEAN" >> clean/low_rating_reviews.csv
grep -i -c 'late delivery' "$CLEAN" > reports/late_delivery_count.txt || true

# --- 6. Server log summary -------------------------------------------------
echo "ERROR lines: $(grep -c '\[ERROR\]' "$RAW_LOG")" > reports/log_summary.txt
echo "WARN lines: $(grep -c '\[WARN\]' "$RAW_LOG")" >> reports/log_summary.txt
echo "Top 5 error messages (count message):" >> reports/log_summary.txt
grep '\[ERROR\]' "$RAW_LOG" | tr -d '\r' | cut -d' ' -f5- | sort | uniq -c | sort -rn | head -n 5 >> reports/log_summary.txt

echo "Done. Clean files are in clean/, reports are in reports/."
