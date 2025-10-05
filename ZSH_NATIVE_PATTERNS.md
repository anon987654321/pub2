# ZSH Native Patterns - Replacing awk/sed/tr/grep

**Philosophy:** No external forks, pure zsh parameter expansion for maximum performance.

## String Operations

```zsh
# Remove CRLF line endings
cleaned=${var//$'\r'/}

# Case conversion
lower=${(L)var}
upper=${(U)var}

# Replace all occurrences
result=${var//search/replace}

# Trim whitespace
trimmed_start=${var##[[:space:]]#}
trimmed_end=${var%%[[:space:]]#}
trimmed_both=${${var##[[:space:]]#}%%[[:space:]]#}

# Extract nth field (comma-delimited)
fourth_column=${${(s:,:)line}[4]}

# Split string to array
arr=( ${(s:delim:)var} )
```

## Array Operations

```zsh
# Filter matching patterns (like grep)
matches=( ${(M)arr:#*pattern*} )

# Filter excluding patterns (inverse grep)
non_matches=( ${arr:#*pattern*} )

# Get unique elements (like uniq)
unique=( ${(u)arr} )

# Join array with delimiter
joined=${(j:,:)arr}

# Reverse array
reversed=( ${(Oa)arr} )

# Sort array
sorted=( ${(o)arr} )           # ascending
sorted_desc=( ${(O)arr} )      # descending
```

## Pattern Matching

```zsh
# grep equivalent
lines=( ${(M)lines:#*query*} )

# awk column extraction
col=${${(s:,:)line}[4]}

# tr character mapping
declare -A charmap=( a 1 b 2 )
mapped=${text//(#m)?/${charmap[$MATCH]}}

# uniq equivalent
unique_arr=( ${(u)arr} )
```

## Parameter Expansion Flags

- `M` - Match instead of filter
- `u` - Unique elements
- `o` - Sort ascending
- `O` - Sort descending
- `L` - Lowercase
- `U` - Uppercase
- `j` - Join array
- `s` - Split string
- `A` - Assign to array

## Avoid These External Commands

**Replace:**
- `awk` → zsh array/string operations
- `sed` → zsh parameter expansion
- `tr` → zsh case conversion / character mapping
- `grep` → zsh pattern matching with `(M)` flag
- `cut` → zsh field splitting with `(s:delim:)`
- `head/tail` → zsh array slicing `[1,10]` or `[-5,-1]`
- `uniq` → `${(u)arr}`
- `sort` → `${(o)arr}`

## Exceptions

Use external tools only for:
- Complex regex requiring PCRE
- Multi-file operations
- Binary data processing
