#!/bin/bash
echo "Building Booze Elroy..."

# Create a zip file of the game (excluding build artifacts)
zip -r booze-elroy.zip *.lua sprites moonshine -x "*.zip" "*.exe"

# Concatenate love executable with the zip file
# Note: You'll need to have love in your PATH or specify the full path
cat love booze-elroy.zip > booze-elroy.exe

echo "Done! booze-elroy.exe created."
echo ""
echo "Note: Make sure 'love' executable is in your PATH or modify this script to use the full path."


