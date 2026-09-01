#!/bin/bash

rd() {
  # Function to open and start writing on the research diary, adding the date if necessary.
  
  local diary_dir months_dir main_file

  diary_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)" || return 1
  months_dir="${diary_dir}/months"
  main_file="${diary_dir}/main.tex"

  local current_month month_title current_date ref_date

  current_month=$(date +%Y-%m)
  month_title="$(date '+%B %Y')"
  echo "Current month is ${current_month}, i.e., ${month_title}."

  current_date="$(date -I) ($(date +%A))"
  echo "Current date: ${current_date}."

  # ref_date is the current date without day of the week, for cross-referencing.
  ref_date="$(date -I)"

  local month_file include_line date_heading tmp
  month_file="${months_dir}/${current_month}.tex"
  include_line="\\include{months/${current_month}}"
  date_heading="\\section*{\\color{teal}${current_date}}"

  # Create months folder unless it already exists, and return from the function with failure status 1 if it is not possible to create the directory for some reason.
  mkdir -p "$months_dir" || return 1

  # Make sure that main.tex exists.
  if [[ ! -f "$main_file" ]]; then 
    printf 'Error: main.tex file does not exist: %s\n' "$main_file" >&2
    return 1
  fi

  # Create month file the frist time this month is used.
  if [[ ! -f "$month_file" ]]; then
    printf '%s\n\n' "\\chapter{${month_title}}" > "$month_file" || return 1
  fi

  # Include month file in main.tex if necessary.
  if ! grep -Fxq "$include_line" "$main_file"; then
    # Edit a temporary file first for safety.
    tmp="$(mktemp "${main_file}.tmp.XXXXXX")" || return 1

    awk -v new="$include_line" '
      {
        lines[NR] = $0

        if ($0 ~ /\\include\{months\//) {
          last_include = NR
        }

        if ($0 ~ /Monthly files:/ && !monthly_marker) {
          monthly_marker = NR
        }
      }

      END {
        target = last_include ? last_include : monthly_marker

        for (i = 1; i <= NR; i++) {
          print lines[i]

          if (target && i == target) {
            print new
            inserted = 1
          }
        }

        if (!inserted) {
          print "Error: could not find a place to insert the monthly include." > "/dev/stderr"
          exit 1
        }
      }
    ' "$main_file" > "$tmp" &&
    chmod --reference="$main_file" "$tmp" &&
    mv "$tmp" "$main_file" || {
      rm -f "$tmp"
      return 1
    }
  fi

  # Add today's heading if necessary.
  if ! grep -Fxq "$date_heading" "$month_file"; then
    {
      printf '\n'
      printf '%s\n' "$date_heading"
      printf '%s\n' "\\phantomsection\\label{day:${ref_date}}"
      printf '\n'
    } >> "$month_file" || return 1
  fi

  command -v vim >/dev/null || {
    printf 'Error: vim was not found.\n' >&2
    return 1
  }

  (
    cd "$months_dir" || exit 1
    vim '+normal! Go' '+startinsert' "${current_month}.tex"
  )
}
