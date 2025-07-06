import base64
import os
import random
import string
from openai import OpenAI
from pydantic import BaseModel
from enum import Enum
from typing import Optional
import argparse


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
def get_filename(file_path):

    abs_path = os.path.abspath(file_path)  # Resolve to an absolute path
    filename_with_extension = os.path.basename(
        abs_path
    )  # Get the filename with extension
    filename, _ = os.path.splitext(
        filename_with_extension
    )  # Split filename and extension
    return filename


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
base_output_path = "/home/willh/.dotfiles/scripts/python/questions/extracted/"

filename = get_filename(image_path)

parsed_data = {
    "year": None,
    "month": None,
    "administered": None,
    "version": None,
    "module": None,
    "test": "math",
    "test_id": None,
    "question_number": None,
}

test = parsed_data["test"]


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
source-id: real-{filename}
test-id: {parsed_data['test_id']}
question-number: {parsed_data['question_number']}
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
    output_path = f"{base_output_path}/{filename}.md"
    # print(f"response message {question_markdown}")

    os.makedirs(base_output_path, exist_ok=True)
    with open(output_path, "w") as output_file:
        output_file.write(question_markdown)

    print(f"Response written to {output_path}")

print(f"Response written to {response_data.num_questions}")
