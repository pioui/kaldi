#!/bin/bash

# Create nessesary files from usc data and folder structure.
# give input argument that /usc folder directory
# Usage:
#   bash scripts/step4.sh /home/.../data/usc


# First directory that we want to create
DATA_DIR="data"

# First input argument is the directory of usc data 
USC_DIR=${1}

# We define the list of directories to create
DIRECTORIES=("train" "dev" "test" "lang" "local" "local/dict" "local/lm_tmp" "local/nist_lm")


# Check if the directory and subdirectory exist
if [ -d "$DATA_DIR" ]; then
    echo "Directory $dir already exists."
else
    # Create the directory
    mkdir "$DATA_DIR"
    echo "Directory $DATA_DIR created."
fi

# Loop over each directory name and check if it exists
for subdir in "${DIRECTORIES[@]}"; do
    if [ -d "$DATA_DIR/$subdir" ]; then
        echo "Directory $DATA_DIR/$subdir already exists."
    else
        # Create the directory
        mkdir "$DATA_DIR/$subdir"
        echo "Directory $DATA_DIR/$subdir created."
    fi
done

# Set the source and destination filenames
SRC_FILE=("$USC_DIR/filesets/training.txt" "$USC_DIR/filesets/validation.txt" "$USC_DIR/filesets/testing.txt")
DST_FILE="uttids"
DIRECTORIES=("train" "dev" "test")

for i in "${!SRC_FILE[@]}"; do
    # Get the elements from both lists at the current index
    element1="${DIRECTORIES[$i]}"
    element2="${SRC_FILE[$i]}"

    # We copy the contents of the source file to the destination file
    cp -p "$element2" "$element1/$DST_FILE"

    # Copy was successful
    echo "Copied contents of ${SRC_FILE[$i]} to $DATA_DIR/$element2/$DST_FILE."

    # Set the input and output filenames
    input_file="$DATA_DIR/$element1/$DST_FILE"
    output_file="$DATA_DIR/$element1/utt2spk"

    # Loop over each line of the input file
    while read line; do
      # Extract the first two characters of the line
      prefix="${line:0:2}"

      # Write the original line and prefix to the output file
      echo "$line $prefix" >> "$output_file"
    done < "$input_file"

    # Set the input and output filenames
    input_file="$DATA_DIR/$element1/$DST_FILE"
    output_file="$DATA_DIR/$element1/wav.scp"

    # Loop over each line of the input file
    while read line; do
      # Write the utterance_id and the path to the .wav file
      echo "$line ../../wav/$line.wav" >> "$output_file"
    done < "$input_file"

    # Set the input and lookup filenames, and the output filename
    input_file="$DATA_DIR/$element1/$DST_FILE"
    lookup_file="$USC_DIR/transcriptions.txt"
    output_file="$DATA_DIR/$element1/text2"

    # Loop over each line of the input file
    while read line; do
      # Extract the prefix and the last three characters of the prefix
      prefix="$line"
      suffix="${prefix:(-3)}"
      # Look up the corresponding text in the lookup file
      text=$(grep "^$suffix" "$lookup_file" | cut -f 2-)
      # Write the prefix and text to the output file
      echo "$prefix $text" >> "$output_file"
    done < "$input_file"
done


# Finally we call the python script which will replace the phonemes
python3 phoneme.py
