{{/* NOTE: Most of the methods output JSON as it was easier to debug with... */}}

{{/*
  pt1.splitPuzzleLines
  Splits a text blob into lines for easier processing
*/}} 
{{- define "pt1.splitPuzzleLines" -}}
{{- $split_lines := splitList "\n" . -}}
{{/* I don't think the below is necessary anymore but I've spent more time than I care for to clean this up. */}}
{{- $lines := list }}
{{- range $k, $v := $split_lines }}
  {{/* Add lines one-by-one, removing empty lines */}}
  {{- if ne (len $v) 0 }}
    {{- $lines = append $lines $v -}}
  {{-  end -}}
{{- end -}}
{{ (dict "result" $lines) | toJson }}
{{- end -}}


{{/*
     pt1.findNumberPositionsInString
     Find all numbers in a string and return start pos, end pos, and value
     Given a line, find all numbers, it's start/end pos, number of digits and value

*/}}
{{- define "pt1.findNumberPositionsInString" -}}
{{- $input := . }}
{{- $result := list -}}
{{- $current_number := "" -}}
{{- $start_index := -1 -}}
{{/* Scan the string for numbers */}}
{{- range $index := until (len $input) }}
  {{/* Inspect each character at a time by doing a substr of 1 char long */}}
  {{- $current_char := substr $index (int (add1 $index)) $input }}
  {{/* Check if the current character is a digit */}}
  {{- if regexMatch "[0-9]" $current_char }}
    {{/* If the current character is a digit and we haven't started a number yet, set start index */}}
    {{- if eq $start_index -1 }}
      {{- $start_index = $index -}}
    {{- end }}
    {{/* Add current character to the number string */}}
    {{- $current_number = print $current_number $current_char }}
  {{- else }}
    {{/* If the current character is not a number, return the string if it's a number */}}
    {{- if ne $current_number "" }}
      {{- $result = append $result (dict "start_pos" $start_index "end_pos" $index "number" $current_number) -}}
      {{- $current_number = "" -}}
      {{- $start_index = -1 -}}
    {{- end }}
  {{- end }}
{{- end }}
{{/* If we hit the end of the line, dump the number string if not ended yet */}}
{{- if ne $current_number "" }}
  {{- $result = append $result (dict "start_pos" $start_index "end_pos" (sub (len $input) 1) "number" $current_number) -}}
{{- end }}
{{- dict "result" $result | toJson -}}
{{- end -}}


{{/*
  pt1.findPartNumbers
  Find all part numbers by seeing which numbers touch a non-digit, non-period
  symbol. A part number is valid if the number is on the sides, above/below
  or diagnonal.
*/}}
{{- define "pt1.findPartNumbers" -}}
{{- $part_nums := list -}}
{{- $input := .result  -}}
{{- $lineno := 0 }}
{{- $end_line_num := sub (len .result) 1 -}}
{{/* Run this for each individual line at a time */}}
{{- range $line := $input }}
  {{/* Force line to be interpreted as a string */}}
  {{- $line = toString $line }}
  {{/* Find all numbers and their positions in the line */}}
  {{- $nums_in_line := include "pt1.findNumberPositionsInString" $line | fromJson -}}
  {{/* For each found number, check to see if it touches a symbol */}}
  {{- range $found_num := $nums_in_line.result }}
    {{- $found_above := false -}}
    {{- $found_below := false -}}
    {{- $found_sides := false }}
    {{- $line_to_chk := "" -}}
    {{/* Check around the numbers */}}
    {{/* Check next to each number for a symbol */}}
    {{- $num_start_pos := max 0 (sub $found_num.start_pos 1) -}}
    {{- $num_end_pos := min (add $found_num.end_pos 1) (len $line)  }}
    {{- $search_target := substr (int $num_start_pos) (int $num_end_pos) $line -}}
    {{/* The substring contains the letters adjacent to the number. Check if any
         symbol exists */}}
    {{- if ne (regexFind "[^0-9\\.]" $search_target) "" -}}
      {{- $found_sides = true -}}
    {{- end -}}
    {{/* If we're below the first line, check the line above us */}}
    {{- if gt $lineno 0 -}}
      {{- $line_to_search := index $input (sub $lineno 1) }}
      {{- $search_target := substr (int $num_start_pos) (int $num_end_pos) $line_to_search -}}
      {{- if ne (regexFind "[^0-9\\.]" $search_target) "" -}}
        {{- $found_above = true -}}
      {{- end -}}
    {{- end -}}
    {{/* If we're above the last line, check the line below us */}}
    {{- if lt $lineno $end_line_num -}}
      {{- $line_to_search := index $input (add $lineno 1) }}
      {{- $search_target := substr (int $num_start_pos) (int $num_end_pos) $line_to_search -}}
      {{- if ne (regexFind "[^0-9\\.]" $search_target) "" -}}
        {{- $found_below = true -}}
      {{- end -}}
    {{- end -}}
    {{/* See if we found anything.. */}}
    {{- if (or $found_sides $found_above $found_below)  -}}
      {{ $part_nums = append $part_nums (get $found_num "number") }}
    {{- end -}}
  {{- end -}}  
  {{- $lineno = add $lineno 1 -}}
{{- end -}}
{{ (dict "result" $part_nums) | toJson }}
{{- end -}}

{{/*
  pt1.addResults
  Convenience function to sum the list of results
*/}}
{{- define "pt1.addResults" -}}
{{- $input := . }}
{{- $total := 0 }}
{{- range . }}
{{- $total = add $total . -}}
{{- end -}}
{{ $total }}
{{- end -}}

{{/* 
  pt1.Solution
  Finds all valid part numbers in a puzzle specified by .Values.puzzle
*/}}
{{- define "pt1.solution" -}}
{{- $lines := include "pt1.splitPuzzleLines" .Values.puzzle | fromJson -}}
{{- $part_numbers := include "pt1.findPartNumbers" $lines | fromJson }}
{{- $finalNum := include "pt1.addResults" (get ($part_numbers) "result") }}
{{ $finalNum }}
{{- end -}}