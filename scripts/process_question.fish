#!/usr/bin/env fish

# Check if the correct number of arguments is provided
if test (count $argv) -ne 2
    echo "Usage: ./process_yaml.fish <input_file> <output_dir>"
    exit 1
end

# Assign input file and output directory from arguments
set input_file $argv[1]
set output_dir $argv[2]

# Ensure output directory exists
mkdir -p $output_dir

# Extract the base filename (without extension) for the output
set filename (basename $input_file .md)

# Extract content after the YAML front matter
set content (awk 'f{print} /^---$/{c++; if(c==2) f=1}' $input_file)

# echo $content
# set content "some content"

set content_base64 (echo $content | base64)
# Convert the YAML front matter to JSON using yq's front-matter option
set raw_json_output (yq --front-matter=extract '.content="'(echo $content_base64)'"' $input_file | yq -o=json '.' )

# Save the JSON to the output directory
echo "$raw_json_output" > $output_dir/$filename.json

echo "Processed $input_file into $output_dir/$filename.json"
