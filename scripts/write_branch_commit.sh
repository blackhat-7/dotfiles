#!/bin/bash

# Exit if the hook is supposed to be skipped
if [ ! -z "$SKIP_POST_COMMIT_HOOK" ]; then
    exit 0
fi

# Fetch current branch name
branch_name=$(git branch --show-current)
# Fetch latest commit hash
commit_hash=$(git rev-parse HEAD)

# Define the file path
file="pyproject.toml"

# Read current branch and commit from pyproject.toml
current_branch=$(grep "^branch =" $file | cut -d'"' -f2)
current_commit=$(grep "^commit =" $file | cut -d'"' -f2)

# Function to update pyproject.toml
update_pyproject() {
    local key="$1"
    local value="$2"

    if grep -q "^${key} =" "$file"; then
        sed -i.bak "s/^${key} =.*/${key} = \"${value}\"/" "$file" && rm -f "$file.bak"
    else
        echo "${key} = \"${value}\"" >> "$file"
    fi
}

# Flag to track if any update was made
updates_made=false

# Check and update branch in pyproject.toml if necessary
if [ "$branch_name" != "$current_branch" ]; then
    update_pyproject "branch" "$branch_name"
    updates_made=true
fi

# Check and update commit in pyproject.toml if necessary
if [ "$commit_hash" != "$current_commit" ]; then
    update_pyproject "commit" "$commit_hash"
    updates_made=true
fi

# Commit the changes only if updates were made and avoid the hook
if [ "$updates_made" = true ]; then
    git add $file
    # Use a condition to prevent the hook from running or use an environment variable
    export SKIP_POST_COMMIT_HOOK=1
    git commit --amend --no-edit --no-verify
fi
