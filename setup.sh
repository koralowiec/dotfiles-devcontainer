#!/usr/bin/env bash

CONTINUE_ON_ERROR=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --continue-on-error)
            CONTINUE_ON_ERROR=true
            shift
            ;;
    esac
done

# Set error handling
if [ "$CONTINUE_ON_ERROR" = false ]; then
    set -e
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$SCRIPT_DIR/scripts"

# Check if scripts directory exists
if [ ! -d "$SCRIPTS_PATH" ]; then
    echo "ERROR: scripts directory not found at $SCRIPTS_PATH"
    exit 1
fi

# Find all .sh files in scripts directory and sort alphabetically
SCRIPTS=($(find "$SCRIPTS_PATH" -maxdepth 1 -type f -name "*.sh" | sort))

if [ ${#SCRIPTS[@]} -eq 0 ]; then
    echo "No scripts found in $SCRIPTS_PATH"
    exit 0
fi

echo "Starting dotfiles setup..."

FAILED_SCRIPTS=()
SUCCESS_COUNT=0

# Execute each script
for script in "${SCRIPTS[@]}"; do
    script_name=$(basename "$script")
    echo "Executing: $script_name"
    
    if bash "$script"; then
        ((SUCCESS_COUNT++))
    else
        EXIT_CODE=$?
        echo "✗ $script_name failed with exit code $EXIT_CODE"
        FAILED_SCRIPTS+=("$script_name")
        
        if [ "$CONTINUE_ON_ERROR" = false ]; then
            echo ""
            echo "Setup failed. Stopping execution."
            exit $EXIT_CODE
        fi
    fi
done

# Print summary
echo "Setup complete!"
echo "Successfully executed: $SUCCESS_COUNT/${#SCRIPTS[@]} scripts"

if [ ${#FAILED_SCRIPTS[@]} -gt 0 ]; then
    echo "Failed scripts:"
    for failed in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $failed"
    done
    exit 1
fi

exit 0
