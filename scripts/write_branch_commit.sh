#!/bin/bash

# Fetch current branch name
branch_name=$(git branch --show-current)
# Fetch latest commit hash
commit_hash=$(git rev-parse HEAD)

# Define the file path
file="pyproject.toml"

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
update_pyproject "branch" "$branch_name"

# Check and update commit in pyproject.toml if necessary
update_pyproject "commit" "$commit_hash"

# Commit the changes only if updates were made and avoid the hook
git add $file
# Use a condition to prevent the hook from running or use an environment variable
git commit --amend --no-edit --no-verify
