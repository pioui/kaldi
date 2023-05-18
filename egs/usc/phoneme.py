import os
import re

# TODO: input argument usc/ directory


# Set the input, lookup and the output filename
input_files = ["data/train/text2", "data/test/text2", "data/dev/text2"]
lookup_file = "/home/pigi/data/usc/lexicon.txt"
output_files = ["data/train/text", "data/test/text", "data/dev/text"]

# Read the lookup file into a dictionary
lookup_dict = {}
with open(lookup_file, "r") as f:
    for line in f:
        parts = line.strip().split("\t ")
        if len(parts) == 1:
            parts = line.split("\t")
        lookup_dict[parts[0]] = parts[1]

# Open the input and output files
for i in range(3):
    with open(input_files[i], "r") as f_in, open(output_files[i], "w") as f_out:
        # Loop over each line of the input file
        for line in f_in:
            id = line.strip().split(" ")[0]
            line = line.strip().lower()
            line = re.sub(r'[^a-z\']', ' ', line)
            f_out.write(id + " sil ")
            for word in line.split(" ")[1:]:
                # Look up the corresponding expression in the dictionary
                expression = lookup_dict.get(word.upper(), "")
                if expression != "":
                    f_out.write(expression + " ")
            f_out.write("sil\n")

for file in input_files:
    os.remove(file)
