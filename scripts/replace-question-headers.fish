#!/usr/bin/env fish

function replace_question_headers
    set -l file $argv[1]  # Get the file name from arguments
    set -l count 1

    # Process the file and replace matching lines
    awk -v count=0 '
    /^## Question vid-[A-Za-z0-9-]+$/ {
        count += 1
        print "## Question " count
        next
    }
    { print }
    ' $file > $file.tmp && mv $file.tmp $file
end

replace_question_headers $argv
