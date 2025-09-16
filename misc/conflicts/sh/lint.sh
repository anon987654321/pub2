#!/usr/bin/env zsh

# Ensure extended globbing and nullglob are enabled for better file matching
setopt extended_glob nullglob

# Function to install necessary tools
install_tools() {
    echo "Installing Ruby gems..."
    gem install --user-install rubocop rubocop-performance rubocop-rspec syntax_tree syntax_tree-rbs erb_lint reek brakeman

    echo "Installing Node.js packages..."
    npm install --save-dev prettier
}

# Function to configure Ruby linting rules
configure_ruby_linting() {
    cat <<EOL > ~/.rubocop.yml
require: rubocop-performance

AllCops:
  Exclude:
    - '.node_modules/**/*'
    - '.vendor/**/*'

Layout/IndentationConsistency:
  EnforcedStyle: normal
Layout/IndentationWidth:
  Width: 2
Layout/SpaceInsideStringInterpolation:
  EnforcedStyle: space
Layout/LineLength:
  Enabled: false
Layout/EmptyLineBetweenDefs:
  Enabled: true
Layout/EndAlignment:
  EnforcedStyleAlignWith: start_of_line
Layout/EmptyLinesAroundMethodBody:
  Enabled: true
Layout/CommentIndentation:
  Enabled: true

Style/StringLiterals:
  EnforcedStyle: double_quotes

Style/IfUnlessModifier:
  Enabled: true
Style/MultilineIfThen:
  Enabled: true
Style/BlockDelimiters:
  EnforcedStyle: line_count_based

Style/RedundantSelf:
  Enabled: true
Style/HashSyntax:
  EnforcedStyle: ruby19
Style/EmptyLiteral:
  Enabled: true

Lint/UnusedBlockArgument:
  Enabled: true
Lint/UnusedMethodArgument:
  Enabled: true

Performance/RedundantMerge:
  Enabled: true
Performance/StartWith:
  Enabled: true

Metrics/MethodLength:
  Max: 10
Metrics/CyclomaticComplexity:
  Enabled: true
  Max: 6
Metrics/PerceivedComplexity:
  Enabled: true
  Max: 7

Style/AsciiComments:
  Enabled: true
Style/RaiseArgs:
  Enabled: true
Style/OptionalArguments:
  Enabled: true
Style/SafeNavigation:
  Enabled: true

Naming/MethodName:
  Enabled: true
  EnforcedStyle: snake_case
Naming/VariableName:
  Enabled: true
  EnforcedStyle: snake_case

Style/FrozenStringLiteralComment:
  Enabled: true
Style/MutableConstant:
  Enabled: false
Style/OptionalBooleanParameter:
  Enabled: true
Style/RedundantSortBy:
  Enabled: true
EOL
}

# Function to run linters on Ruby files
lint_ruby_file() {
    local file=$1
    if [[ -s $file ]]; then
        reek32 --no-color "$file"
        rubocop32 --verbose --autocorrect-all --config ~/.rubocop.yml "$file"
    fi
}

# Function to lint ERB files in a Rails project
lint_erb_file() {
    local file=$1
    if [[ -s $file ]]; then
        erblint32 --lint-all --autocorrect "$file"
    fi
}

# Main linting process
main_lint_process() {
    for file in **/*.{rb,rake}(D); do
        lint_ruby_file "$file"
    done

    if [[ -f "bin/rails" ]]; then
        for file in app/**/*.html.erb(D); do
            lint_erb_file "$file"
        done
        npx stylelint "app/**/*.scss" &
        npx prettier --write "app/**/*.{js,css}" &
        wait # Wait for all background jobs to complete
        brakeman32 -A
    fi
}

# Cleanup function and error handling
cleanup() {
    echo "Linting completed. Check logs for details."
}
trap cleanup EXIT

# Run installation and configuration
install_tools
configure_ruby_linting

# Execute main linting process
main_lint_process
