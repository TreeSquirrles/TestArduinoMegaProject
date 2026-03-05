#!/bin/bash

# Define paths
DIR="./Test"
CPP_FILE="$DIR/main.cpp"
INO_FILE="$DIR/Test.ino"
BOARD="arduino:avr:mega:cpu=atmega2560"
PORT="/dev/ttyACM0"
BAUD_RATE=9600

# ---------------------------------------------------------
# PRE-CHECK: Auto-fix stranded files from previous crashes
# ---------------------------------------------------------
if [ ! -f "$CPP_FILE" ] && [ -f "$INO_FILE" ]; then
    echo "Found stranded .ino file. Restoring to .cpp..."
    mv "$INO_FILE" "$CPP_FILE"
fi

# Check if the source CPP file exists
if [ ! -f "$CPP_FILE" ]; then
    echo "Error: $CPP_FILE not found."
    exit 1
fi

# ---------------------------------------------------------
# SAFETY MECHANISM:
# The 'trap' command ensures the cleanup function runs 
# whenever the script exits (success, error, or Ctrl+C).
# ---------------------------------------------------------
cleanup() {
    # We check if INO exists first so this function is safe to call multiple times
    if [ -f "$INO_FILE" ]; then
        mv "$INO_FILE" "$CPP_FILE"
        echo "Restored $CPP_FILE"
    fi
}
trap cleanup EXIT

# 1. Rename .cpp -> .ino so Arduino CLI can find the sketch
echo "Renaming source to .ino..."
mv "$CPP_FILE" "$INO_FILE"

# 2. Compile
echo "Compiling..."
# If this fails, the script exits, triggering 'trap cleanup' automatically
arduino-cli compile -b "$BOARD" "$DIR" || exit 1

# 3. Upload
echo "Uploading..."
arduino-cli upload -b "$BOARD" -p "$PORT" "$DIR" || exit 1

echo "Success!"

# ---------------------------------------------------------
# EXPLICIT RESTORE
# We manually run cleanup here so the file is back to .cpp
# while you are looking at the screen session.
# ---------------------------------------------------------
cleanup

# 4. Monitor
# The trap will run again when screen closes, but 'cleanup'
# handles that safely because the file is already moved.
echo "Opening serial monitor..."
screen "$PORT" $BAUD_RATE
