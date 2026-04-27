#!/usr/bin/env python3
"""
Parses recipe markdown files to generate a consolidated Bill of Materials (BOM).
Excludes cross-reference markers from the final output.
"""

import argparse
import re
from pathlib import Path
import yaml

def sanitize_text(text: str) -> str:
    """Removes cross-reference markers to ensure clean BOM output."""
    # Strip Markdown/Pandoc cross-references (e.g., {#ref}, [@ref])
    text = re.sub(r'\{#.*?\}', '', text)
    text = re.sub(r'\[@.*?\]', '', text)
    # Strip LaTeX cross-references if embedded
    text = re.sub(r'\\(?:ref|label|cref)\{.*?\}', '', text)
    return text.strip()

def parse_recipe_file(filepath: Path) -> list:
    """Extracts the ingredients list from a single markdown recipe."""
    ingredients = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except IOError as e:
        print(f"Error reading {filepath}: {e}")
        return ingredients

    # Isolate YAML frontmatter and markdown body
    yaml_match = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
    if not yaml_match:
        return ingredients

    body_text = yaml_match.group(2)
    in_ingredients = False

    # Extract bullet points under the Ingredients heading
    for line in body_text.split('\n'):
        if re.match(r'^##\s+Ingredients', line, re.IGNORECASE):
            in_ingredients = True
            continue
        elif in_ingredients and re.match(r'^##\s+', line):
            break  # Stop execution upon reaching the next section

        if in_ingredients:
            list_match = re.match(r'^\s*[\*\-]\s+(.*)', line)
            if list_match:
                item = sanitize_text(list_match.group(1))
                if item:
                    ingredients.append(item)

    return ingredients

def main():
    parser = argparse.ArgumentParser(description="Generate BOM from markdown recipes.")
    parser.add_argument('-d', '--directory', type=Path, default=Path('recipes'), 
                        help="Directory containing .md recipes")
    parser.add_argument('-o', '--output', type=Path, default=Path('BOM.md'), 
                        help="Output file path for the compiled BOM")
    args = parser.parse_args()

    master_bom = []
    if args.directory.exists() and args.directory.is_dir():
        for filepath in args.directory.glob('*.md'):
            master_bom.extend(parse_recipe_file(filepath))
    else:
        print(f"Target directory '{args.directory}' not found.")
        return

    # Deduplicate and sort the final BOM
    unique_ingredients = sorted(list(set(master_bom)))

    try:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write("# Master Bill of Materials\n\n")
            for item in unique_ingredients:
                f.write(f"* {item}\n")
    except IOError as e:
        print(f"Error writing to {args.output}: {e}")

if __name__ == "__main__":
    main()