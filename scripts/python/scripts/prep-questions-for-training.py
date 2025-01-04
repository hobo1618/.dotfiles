import os
from pathlib import Path


def process_markdown_file(file_path):
    """
    Processes a markdown file to:
    1. Remove the '## Question <id>' header.
    2. Remove everything after '## Rationale'.
    3. Replace all line breaks with explicit \n.
    """
    with open(file_path, "r") as f:
        content = f.read()

    # Remove '## Rationale' section
    if "## Rationale" in content:
        content = content.split("## Rationale", 1)[0].strip()

    # Remove the '## Question <id>' header
    lines = content.split("\n")
    filtered_lines = [line for line in lines if not line.startswith("## Question")]
    content = "\n".join(filtered_lines).strip()

    # Replace line breaks with explicit \n
    content = content.replace("\n", "\\n")

    return content


def process_directory(directory):
    """
    Processes all markdown files in a directory.
    """
    for file in Path(directory).glob("*.md"):
        processed_content = process_markdown_file(file)
        with open(file, "w") as f:
            f.write(processed_content)
        print(f"Processed: {file}")


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print("Usage: python process_markdown.py <directory>")
    else:
        directory = sys.argv[1]

        if not Path(directory).is_dir():
            print(f"Error: '{directory}' is not a valid directory.")
        else:
            process_directory(directory)
