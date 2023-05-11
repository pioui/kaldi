#!/bin/bash

# First directory that we want to create
dir="data"

# We define the list of directories to create
directories=("train" "dev" "test")

# TODO: input argument usc/ directory

# Check if the directory and subdirectory exist
if [ -d "$dir" ]; then
    echo "Directory $dir already exists."
else
    # Create the directory
    mkdir "$dir"
    echo "Directory $dir created."
fi

# Loop over each directory name and check if it exists
for subdir in "${directories[@]}"; do
    if [ -d "$dir/$subdir" ]; then
        echo "Directory $dir/$subdir already exists."
    else
        # Create the directory
        mkdir "$dir/$subdir"
        echo "Directory $dir/$subdir created."
    fi
done


# Set the source and destination filenames
src_file=("/home/pigi/data/usc/filesets/training.txt" "/home/pigi/data/usc/filesets/validation.txt" "/home/pigi/data/usc/filesets/testing.txt")
dst_file="uttids"


for i in "${!src_file[@]}"; do
    # Get the elements from both lists at the current index
    element1="${directories[$i]}"
    element2="${src_file[$i]}"

    # We copy the contents of the source file to the destination file
    cp -p "$element2" "$dir/$element1/$dst_file"

    # Copy was successful
    echo "Copied contents of ${src_file[$i]} to $dir/$element2/$dst_file."

    # Set the input and output filenames
    input_file="$dir/$element1/$dst_file"
    output_file="$dir/$element1/utt2spk"

    # Loop over each line of the input file
    while read line; do
      # Extract the first two characters of the line
      prefix="${line:0:2}"

      # Write the original line and prefix to the output file
      echo "$line $prefix" >> "$output_file"
    done < "$input_file"

    # Set the input and output filenames
    input_file="$dir/$element1/$dst_file"
    output_file="$dir/$element1/wav.scp"

    # Loop over each line of the input file
    while read line; do
      # Write the utterance_id and the path to the .wav file
      echo "$line ../../wav/$line.wav" >> "$output_file"
    done < "$input_file"

    # Set the input and lookup filenames, and the output filename
    input_file="$dir/$element1/$dst_file"
    lookup_file="/home/pigi/data/usc/transcriptions.txt"
    output_file="$dir/$element1/text2"

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
