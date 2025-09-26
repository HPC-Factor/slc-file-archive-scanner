#!/bin/zsh
# © HPC:Factor 2025. Windows CE local archive hash scanner (macOS zsh)
# Version: 1.0.0.20250924-mac
# converted to mac by stingraze on 9/25/2025 - 4:03AM JST using ChatGPT GPT-5
# Usage:
#   1) Optional: pass the archive directory as the first argument.
#        ./hpcfactor_scan_mac.sh "/Volumes/Data/CEArchive"
#   2) Or just run with no args; default: ~/Documents/WindowsCEArchive
#   3) Output written to: ~/Desktop/Windows_CE_Files.txt
#
# Notes:
# - Uses macOS 'md5 -q' (falls back to 'md5sum' if available).
# - Handles spaces/newlines in filenames (NUL-delimited traversal).
# - Use command: chmod +x ./hpcfactor-scanner-mac.sh to use

set -e
set -u
set -o pipefail

ARCHIVE_DIR="${1:-$HOME/Documents/work/hpcfactor}"
OUT_PATH="$HOME/Desktop/Windows_CE_Files.txt"

print ""
print "HPC:Factor"
print "www.hpcfactor.com"
print ""
print "Creates a file and MD5 hash listing of your Windows CE file archive for comparison with the HPC:Factor Download Centre, SCL and HCL"
print ""
print "Processing Files under:"
print -- "$ARCHIVE_DIR"
print ""

# Ensure archive directory exists; create if missing and exit so the user can populate it.
if [[ ! -d "$ARCHIVE_DIR" ]]; then
  mkdir -p "$ARCHIVE_DIR"
  print "Created: $ARCHIVE_DIR"
  print "Please place your Windows CE archive files there, then run this script again."
  exit 1
fi

# Reset output file
[[ -f "$OUT_PATH" ]] && rm -f "$OUT_PATH"

# Helpers
get_size() {
  local f="$1"
  if stat -f%z "$f" >/dev/null 2>&1; then
    stat -f%z "$f"           # macOS/BSD stat
  elif stat -c%s "$f" >/dev/null 2>&1; then
    stat -c%s "$f"           # GNU stat fallback
  else
    wc -c < "$f" | tr -d ' ' # universal (slower)
  fi
}

get_md5() {
  local f="$1"
  if command -v md5 >/dev/null 2>&1; then
    md5 -q "$f"              # macOS md5 (quiet hash only)
  elif command -v md5sum >/dev/null 2>&1; then
    md5sum "$f" | awk '{print $1}'
  else
    print "ERROR: Neither 'md5' nor 'md5sum' found." >&2
    exit 2
  fi
}

typeset -i count=0

# Use process substitution so the loop runs in the current shell (count is preserved)
while IFS= read -r -d '' file; do
  print "Processing ${file}"
  filename="${file:t}"            # zsh basename
  size="$(get_size "$file")"
  hash="$(get_md5 "$file")"
  printf "%s|%s|%s|%s\n" "$file" "$filename" "$size" "$hash" >> "$OUT_PATH"
  (( count += 1 ))
done < <(find "$ARCHIVE_DIR" -type f \
          \( -iname "*.exe" -o -iname "*.msi" -o -iname "*.cab" -o -iname "*.zip" -o -iname "*.lzh" \) \
          -print0)

if (( count > 0 )); then
  print ""
  print "Created file log at: $OUT_PATH"
  print "Done! Processed $count file(s)."
  print ""
  print "Please upload your file at 'https://www.hpcfactor.com/downloads/archive-check/' to see if you have something that the community does not."
else
  : > "$OUT_PATH"
  print "No matching files were found under: $ARCHIVE_DIR"
  print "An empty log was created at: $OUT_PATH"
fi
