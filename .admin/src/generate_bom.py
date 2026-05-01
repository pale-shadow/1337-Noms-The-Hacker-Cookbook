"""
Parses recipe markdown files to generate a consolidated Bill of Materials (BOM).
Automatically scans top-level recipe directories (e.g., APPETIZERS, BREAKFAST) 
and excludes cross-reference markers from the final output.
"""

import argparse
import re
from pathlib import Path

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
    parser = argparse.ArgumentParser(description="Generate BOM from top-level markdown recipes.")
    # Assuming the script runs from within .admin/, the repo root is ..
    parser.add_argument('-b', '--base-dir', type=Path, default=Path('..'), 
                        help="Base repository directory to scan")
    parser.add_argument('-o', '--output', type=Path, default=Path('../BOM.md'), 
                        help="Output file path for the compiled BOM")
    parser.add_argument('-e', '--exclude', nargs='+', default=['.admin', '.git', '.venv', 'venv'],
                        help="Directories to exclude from scanning")
    args = parser.parse_args()

    master_bom = []
    base_dir = args.base_dir.resolve()

    if not base_dir.exists() or not base_dir.is_dir():
        print(f"Error: Base directory '{base_dir}' not found.")
        return

    print(f"Scanning repository root: {base_dir}")
    
    # Iterate through top-level directories only
    for item in base_dir.iterdir():
        # Skip files, hidden directories (like .git), and explicitly excluded directories
        if item.is_dir() and not item.name.startswith('.') and item.name not in args.exclude:
            print(f" -> Searching in directory: {item.name}/")
            # Find all markdown files in this directory
            for filepath in item.rglob('*.md'):
                master_bom.extend(parse_recipe_file(filepath))

    # Deduplicate and sort the final BOM
    unique_ingredients = sorted(list(set(master_bom)))

    try:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write("# Master Bill of Materials\n\n")
            if not unique_ingredients:
                f.write("*No ingredients found. Ensure recipes have '## Ingredients' and YAML frontmatter.*\n")
            for item in unique_ingredients:
                f.write(f"* {item}\n")
        print(f"\nSuccess: BOM generated at {args.output.resolve()}")
    except IOError as e:
        print(f"Error writing to {args.output}: {e}")

if __name__ == "__main__":
    main()