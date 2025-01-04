import yaml
from pathlib import Path
from enum import Enum


class Module(Enum):
    STANDARD = "Standard"
    LOWER = "Lower"
    UPPER = "Upper"


class Test(Enum):
    MATH = "Math"
    READING = "Reading"
    FULL = "Full"


def search_and_sort_questions(directory, test_id, output_file="sorted_questions.md"):
    """
    Search all markdown files in a given directory for questions with a specific test ID,
    sort them by question number, and reformat the output into sections by module and test.
    """
    questions = []

    # Search all markdown files in the specified directory
    for file in Path(directory).glob("*.md"):
        with open(file, "r") as f:
            content = f.read()

            # Split frontmatter and body
            if content.startswith("---"):
                frontmatter, body = content.split("---", 2)[1:]
                metadata = yaml.safe_load(frontmatter)

                # Check for test-id
                if "test-id" in metadata and test_id in metadata["test-id"]:
                    question_number = metadata.get("question-number", float("inf"))
                    module = metadata.get("module", "None")
                    answer = metadata.get("answer", "None")
                    test = metadata.get("test", "None")

                    # Remove the ## Rationale section
                    body = remove_rationale_section(body)

                    # Remove the ## Question <id> header
                    body = remove_question_header(body, metadata["id"])

                    questions.append(
                        (question_number, body, metadata, answer, test, module)
                    )

    # Sort by question-number
    sorted_questions = sorted(questions, key=lambda x: x[0])

    # Filter questions by test and module
    math_questions = [q for q in sorted_questions if q[4] == Test.MATH.value]
    reading_questions = [q for q in sorted_questions if q[4] == Test.READING.value]

    sections = {
        "Reading": {
            "Standard": [q for q in reading_questions if q[5] == Module.STANDARD.value],
            "Lower": [q for q in reading_questions if q[5] == Module.LOWER.value],
            "Upper": [q for q in reading_questions if q[5] == Module.UPPER.value],
        },
        "Math": {
            "Standard": [q for q in math_questions if q[5] == Module.STANDARD.value],
            "Lower": [q for q in math_questions if q[5] == Module.LOWER.value],
            "Upper": [q for q in math_questions if q[5] == Module.UPPER.value],
        },
    }

    # Write to output file
    with open(output_file, "w") as f:
        f.write(f"# Questions for Test ID: {test_id}\n\n")

        # Render each section
        for test_name, modules in sections.items():
            for module_name, questions in modules.items():
                # Write section title
                f.write(f"## Module: {test_name} {module_name} Difficulty\n\n")

                # Write questions
                for index, (question_number, body, metadata, answer, _, _) in enumerate(
                    questions
                ):
                    id = metadata["id"]
                    metadata_note = f"metadata[^{id}]"
                    answer_note = (
                        f"[^{id}]: metadata\n"
                        f"    - Question {id}\n"
                        f"    - answer: {answer}\n"
                        f"    - question number: {question_number}\n"
                    )
                    reformatted_body = (
                        f"### Question {question_number}\n\n"
                        f"{metadata_note}\n\n"
                        f"{body}\n\n"
                        f"{answer_note}\n\n"
                    )
                    f.write(reformatted_body)

    print(f"Sorted and reformatted questions saved to {output_file}")


def remove_rationale_section(body):
    """
    Removes everything after the '## Rationale' section from the body content.
    """
    if "## Rationale" in body:
        return body.split("## Rationale", 1)[0].strip()
    return body


def remove_question_header(body, question_id):
    """
    Removes the '## Question <id>' header from the body content.
    """
    header_to_remove = f"## Question {question_id}"
    return body.replace(header_to_remove, "").strip()


# Example usage
if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python search_sort.py <directory> <test_id>")
    else:
        directory = sys.argv[1]
        test_id = sys.argv[2]

        if not Path(directory).is_dir():
            print(f"Error: '{directory}' is not a valid directory.")
        else:
            search_and_sort_questions(directory, test_id)
