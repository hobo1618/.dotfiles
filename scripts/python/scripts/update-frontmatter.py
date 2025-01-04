import sys
import yaml
from pathlib import Path


def update_yaml_field(file_path, key, value):
    """
    Updates or adds a field in the YAML frontmatter of a markdown file.

    :param file_path: Path to the markdown file.
    :param key: The key to add/update in the YAML frontmatter.
    :param value: The value to set for the key.
    """
    try:
        # Read the file content
        with open(file_path, "r") as f:
            content = f.read()

        # Check if the file has YAML frontmatter
        if content.startswith("---"):
            frontmatter, body = content.split("---", 2)[1:]
            metadata = yaml.safe_load(frontmatter) or {}
        else:
            # No frontmatter; initialize metadata and body
            metadata = {}
            body = content

        # Update or add the field
        metadata[key] = value

        # Write the updated content back to the file
        with open(file_path, "w") as f:
            f.write("---\n")
            yaml.dump(metadata, f, default_flow_style=False)
            f.write("---\n")
            f.write(body)

        print(f"Updated '{key}' in {file_path}")

    except Exception as e:
        print(f"Error updating {file_path}: {e}")


if __name__ == "__main__":
    # Check for proper arguments
    if len(sys.argv) != 4:
        print("Usage: python update_yaml.py <file_path> <key> <value>")
        sys.exit(1)

    file_path = sys.argv[1]
    key = sys.argv[2]
    value = sys.argv[3]

    # Check if the file exists
    if not Path(file_path).is_file():
        print(f"Error: File '{file_path}' does not exist.")
        sys.exit(1)

    update_yaml_field(file_path, key, value)
