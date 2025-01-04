#!/usr/bin/env fish

# Check if the correct number of arguments is provided
if test (count $argv) -ne 1
    echo "Usage: ./process_yaml.fish <input_file>"
    exit 1
end

# Assign input file from arguments
set input_file $argv[1]

# Extract the file extension using 'path extension'
set extension (path extension $input_file)

# Validate the extension
if not contains $extension .mov
    echo "Error: Invalid file type. Please provide a .mov file."
    exit 1
end

# Extract the base path without the extension
set output_file (path change-extension mp4 $input_file)

# Construct the output filename with .mov extension
# set output_file "$base_path.mp4"

# Run ffmpeg to process the file
# ffmpeg -i $input_file -c:v dnxhd -profile:v dnxhr_hq -c:a pcm_s16le -pix_fmt yuv422p $output_file

ffmpeg -i $input_file -vcodec libx264 -acodec aac $output_file

