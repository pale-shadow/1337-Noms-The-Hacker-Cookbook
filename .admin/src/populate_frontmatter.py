#!/usr/bin/env python3
"""
Reads markdown recipes with empty YAML frontmatter, uses the Gemini API to 
infer the missing metadata (prep time, cook time, tags, etc.) from the 
recipe text, and updates the file in place.
"""

import os
import re
import json
import argparse
from pathlib import Path
import yaml

# Using the new modern SDK
from google import genai

def setup_gemini():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set.")
        print("Run: export GEMINI_API_KEY='your_key_here'")
        exit(1)
    
    # The new client automatically picks up the GEMINI_API_KEY env var
    return genai.Client()

def extract_recipe_data(client, recipe_text):
    """Prompts Gemini to extract structured data from unstructured recipe text."""
    prompt = f"""
    Analyze the following recipe and extract the metadata. 
    Return ONLY a valid JSON object matching this exact structure, with no markdown formatting or extra text:
    {{
        "title": "Recipe Name",
        "author": "devsecfranklin",
        "prep_time": 15, // integer in minutes (guess if not explicit)
        "cook_time": 30, // integer in minutes (guess if not explicit)
        "yield": "4 servings",
        "difficulty": "medium", // low, medium, or high
        "tags": ["tag1", "tag2"], // e.g., breakfast, dessert, vegan, high-availability
        "hardware": ["skillet", "mixing bowl"]
    }}
    
    Recipe Text:
    {recipe_text}
    """
    
    try:
        # New SDK syntax for content generation
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )
        
        # Clean up potential markdown code block artifacts from the response
        json_text = response.text.strip().replace('```json', '').replace('```', '')
        return json.loads(json_text)
    except Exception as e:
        print(f"Failed to extract data via API: {e}")
        return None

def process_file(client, filepath):
    """Reads a file, sends body to AI, and updates YAML frontmatter."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split frontmatter and body
    yaml_match = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
    if not yaml_match:
        print(f"Skipping {filepath.name}: No YAML frontmatter found.")
        return

    frontmatter_text = yaml_match.group(1)
    body_text = yaml_match.group(2).strip()

    try:
        data = yaml.safe_load(frontmatter_text)
    except yaml.YAMLError as e:
        print(f"Skipping {filepath.name}: Invalid YAML - {e}")
        return

    # If the title is already filled out, we assume it's done to prevent overwriting
    if data and data.get('title'):
        print(f"Skipping {filepath.name}: Already populated.")
        return

    print(f"Processing {filepath.name}...")
    extracted_data = extract_recipe_data(client, body_text)
    
    if not extracted_data:
        print(f" -> Failed to parse AI response for {filepath.name}")
        return

    # Merge extracted data into the YAML dictionary
    for key, value in extracted_data.items():
        if key in data:
            data[key] = value

    # Reconstruct the file
    new_yaml = yaml.dump(data, sort_keys=False, allow_unicode=True)
    new_content = f"---\n{new_yaml}---\n\n{body_text}\n"

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f" -> Successfully updated {filepath.name}")

def main():
    parser = argparse.ArgumentParser(description="Populate recipe YAML using AI.")
    parser.add_argument('-d', '--directory', type=Path, default=Path('..'), 
                        help="Base directory to scan for recipes")
    parser.add_argument('-e', '--exclude', nargs='+', default=['.admin', '.git', '.venv', 'venv'],
                        help="Directories to exclude")
    args = parser.parse_args()

    client = setup_gemini()
    
    # Fixed the argparse attribute name here (was args.base_dir)
    base_dir = args.directory.resolve()

    for item in base_dir.iterdir():
        if item.is_dir() and not item.name.startswith('.') and item.name not in args.exclude:
            for filepath in item.rglob('*.md'):
                process_file(client, filepath)

if __name__ == "__main__":
    main()