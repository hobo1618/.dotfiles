#!/usr/bin/env fish

function split_video
  set time_file $argv[1]
  set media_file $argv[2]
  if test (count $argv) -gt 2
      set output_dir $argv[3]
  else
      set output_dir "."
  end

    # Ensure output directory exists
  mkdir -p $output_dir


  # Read each line of the time file
   while read start_time stop_time name
      # Generate a default name based on the start time if name is empty
      if test -z "$name"
          set name (string replace -a ":" "-" (string replace -a "." "-" $start_time))
      else
          # Replace colons and periods in the name
          set name (string replace -a ":" "-" (string replace -a "." "-" $name))
      end

     ffmpeg -nostdin -i $media_file -ss "$start_time" -to "$stop_time" -c:v libx264 -crf 18 -preset slow -b:v 2M -c:a  aac "$output_dir/$name".mp4 </dev/tty
 
  end < $time_file
  
end

split_video $argv

