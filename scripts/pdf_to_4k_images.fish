#!/usr/bin/env fish

function pdf_to_4k_images
    set -l input_pdf $argv[1]
    set -l output_dir (basename $input_pdf .pdf)-images

    if test -z "$input_pdf"
        echo "Usage: pdf_to_4k_images.fish <file.pdf>"
        return 1
    end

    if not test -f "$input_pdf"
        echo "File not found: $input_pdf"
        return 1
    end

    mkdir -p $output_dir

    echo "Converting $input_pdf to images in $output_dir..."

    # Using ImageMagick's `magick` for high-quality PNGs at 4K resolution
    magick -density 600 "$input_pdf" -quality 100 -resize 3840x2160^ -gravity center -extent 3840x2160 "$output_dir/page_%03d.png"

    echo "Done. Images saved in $output_dir."
end

pdf_to_4k_images $argv
