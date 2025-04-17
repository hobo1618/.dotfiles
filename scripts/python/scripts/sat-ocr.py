import base64
import os
import random
import string
from openai import OpenAI
from pydantic import BaseModel
from enum import Enum
from typing import Optional
import argparse
import re

api_key = os.getenv("OPENAI_API_KEY")


if not api_key:
    raise ValueError("No OpenAI API key in env")

# Set up the API request to OpenAI
client = OpenAI(api_key=api_key)


# Function to check if the file is a valid .png file
def validate_image(file_path):
    if not os.path.isfile(file_path):
        raise argparse.ArgumentTypeError(f"{file_path} does not exist.")
    if not file_path.lower().endswith((".jpg", ".png")):
        raise argparse.ArgumentTypeError(
            f"{file_path} is not a valid .jpg or .png file."
        )
    return file_path


# Function to get the parent directory name
def get_parent_directory_name(file_path):

    abs_path = os.path.abspath(file_path)  # Resolve to an absolute path
    return os.path.basename(os.path.dirname(abs_path))


class Test(Enum):
    MATH = "Math"
    READING = "Reading"
    FULL = "Full"


class Difficulty(Enum):
    EASY = "Easy"
    MEDIUM = "Medium"
    HARD = "Hard"


class Module(Enum):
    STANDARD = "Standard"
    LOWER = "Lower"
    UPPER = "Upper"


class Administered(Enum):
    US = "US"
    INT = "INT"
    NA = "NA"


class Question(BaseModel):
    id: str
    tags: list[str]
    difficulty: Difficulty
    figure_url: Optional[str]
    domain: Optional[str]
    skills: Optional[str]
    # source_id: str
    # test: Test
    content: str
    # administered: Optional[Administered]
    # module: Optional[Module]
    question_number: int
    rationale: Optional[str]
    reasoning: Optional[str]
    multiple_choice: Optional[bool]
    has_figure: bool


class Questions(BaseModel):
    questions: list[Question]
    num_questions: int


pattern = r"^(\d{4})-(\d{2})-(US|INT|NA)-(\d+)-(F|R1|RL|RU|M1|ML|MU|MNA|RNA)$"


def parse_filename(filename: str):
    print(f"Filename: {filename}")
    # Define the regex pattern for the SAT filename format
    match = re.match(pattern, filename)

    if not match:
        return {
            "year": int(2025),
            "month": "NA",
            "administered": "NA",
            "version": int(0),
            "module": "NA",
            "test": "Math",
            "test_id": f"{filename}",
        }

        raise ValueError(f"Filename doesnt match expected format: {filename}")

    year, month, region, version, module_code = match.groups()

    # Map module codes to meaningful values
    module_mapping = {
        "F": Module.STANDARD.value,
        "R1": Module.STANDARD.value,
        "RL": Module.LOWER.value,
        "RU": Module.UPPER.value,
        "M1": Module.STANDARD.value,
        "ML": Module.LOWER.value,
        "MU": Module.UPPER.value,
        "MNA": Module.STANDARD.value,
        "RNA": Module.STANDARD.value,
    }

    test_mapping = {
        "F": Test.FULL.value,
        "R1": Test.READING.value,
        "RL": Test.READING.value,
        "RU": Test.READING.value,
        "M1": Test.MATH.value,
        "ML": Test.MATH.value,
        "MU": Test.MATH.value,
        "MNA": Test.MATH.value,
        "RNA": Test.READING.value,
    }

    module = module_mapping.get(module_code, "UNKNOWN")
    test = test_mapping.get(module_code, "UNKNOWN")
    administered = Administered[region].value

    return {
        "year": int(year),
        "month": int(month),
        "administered": administered,
        "version": int(version),
        "module": module,
        "test": test,
        "test_id": f"{year}-{month}-{region}-{version}",
    }


# Function to encode an image
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")


# Function to generate a random 8-character ID
def generate_random_id():
    return "".join(random.choices(string.ascii_letters + string.digits, k=8))


# Function to read the system prompt from a markdown file
def read_system_prompt(prompt_path):
    with open(prompt_path, "r") as prompt_file:
        return prompt_file.read().strip()


# system_prompt_path = "/home/willh/Documents/askerra/vault/system-prompt-2.md"

parser = argparse.ArgumentParser(description="Process a .png file.")
parser.add_argument(
    "file",
    type=validate_image,
    help="Path to the .png file to be processed.",
)

args = parser.parse_args()

# Access the file path
image_path = args.file
print(f"Processing file: {image_path}")

base_prompt_path = "/home/willh/.dotfiles/scripts/python/prompts"
base_output_path = "/home/willh/Documents/askerra/vault/sat/tests"

parent_dir_name = get_parent_directory_name(image_path)

parsed_data = parse_filename(parent_dir_name)

test = parsed_data["test"].lower()

system_prompt_path = f"{base_prompt_path}/{test}.md"

initial_message = f"{base_prompt_path}/initial-message-{test}.md.md"

# Getting the system prompt
system_prompt = read_system_prompt(system_prompt_path)

# Getting the base64 strings for all images in the directory
base64_image = encode_image(image_path)

messages = [
    {
        "role": "system",
        "content": system_prompt,
    },
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": initial_message,
            },
            {
                "type": "image_url",
                "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"},
            },
        ],
    },
]

# print(f"Sending {len(content)} user content messages to the API.")

response = client.beta.chat.completions.parse(
    model="gpt-4o",
    messages=messages,
    response_format=Questions,
    max_tokens=10000,
)

# Extract the structured response as JSON
response_data = response.choices[0].message.parsed

if response_data is None:
    print("No response data found.")
    exit(1)


for question in response_data.questions:
    source_id = f"{parent_dir_name}-{question.question_number}"
    new_id = f"vid-{generate_random_id()}"
    link = f"![Figure](/sat/assets/imgs/{new_id}.png)"
    # Create the markdown frontmatter as a string
    figure_link = link if question.has_figure else ""

    # Because Yaml is lowercase
    has_figure = "false"
    if question.has_figure:
        has_figure = "true"

    # Create the markdown frontmatter as a string
    question_markdown = f"""---
id: {new_id}
aliases: []
tags: {question.tags}
difficulty: {question.difficulty.value}
domain: {question.domain}
skills: {question.skills}
source-id: real-{source_id}
test-id: {parsed_data['test_id']}
question-number: {question.question_number}
year: {parsed_data['year']}
month: {parsed_data['month']}
module: {parsed_data['module']}
administered: {parsed_data['administered']}
version: {parsed_data['version']}
test: {parsed_data['test']}
figure: {has_figure}
solutions: false
---

## Question {new_id}

{figure_link}

{question.content}

## Rationale

{question.rationale}
"""
    # Write the markdown frontmatter and content to a file in the sat/ dir
    output_path = f"{base_output_path}/{new_id}.md"
    print(f"response message {question_markdown}")

    os.makedirs(base_output_path, exist_ok=True)
    with open(output_path, "w") as output_file:
        output_file.write(question_markdown)
    print(f"Response written to {output_path}")

print(f"Response written to {response_data.num_questions}")
