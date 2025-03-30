#!/bin/bash

# Iterate through all directories in the current path.
find . -maxdepth 1 -type d -not -path "." -print0 | while IFS= read -r -d $'\0' dir; do
  # Navigate into each directory.
  cd $dir || continue

  # Execute git checkout and git pull commands, handling potential errors.
  git checkout next || git checkout main || echo "Error checking out main in $dir"
  git pull || echo "Error pulling main in $dir"

  # Return to the original directory.
  cd ..
done

echo "Done"
