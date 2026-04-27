# Repository Context: 1337-Noms-The-Hacker-Cookbook

## Project Overview
This repository houses a technical "cookbook" built utilizing a hybrid LaTeX and Markdown documentation engine. The build infrastructure relies on Autotools and containerized Docker environments to ensure cross-platform reproducibility, specifically targeting Debian-based distributions and OpenBSD.

## Directory Architecture
* `/` (Top-Level): Categorized markdown recipe files (e.g., APPETIZERS, BREAKFAST).
* `/.admin/`: Central administrative directory containing build logic, Docker configurations, and auxiliary scripts.
    * `.admin/docker-compose.yml`: Primary orchestration file for the build container.
    * `.admin/src/`: Python utilities for automated repository management.
    * `.admin/tex/`: LaTeX preamble and style definitions.
* `CREDITS.md`: Master table mapping recipe filenames to author handles.
* `BOM.md`: Auto-generated Master Bill of Materials.

## Operational Guidelines

### 1. Build System & Environments
* **Autotools:** Modifications to the build lifecycle must be made in `configure.ac` (requires Autoconf >= 2.72) and `.admin/Makefile.am`.
* **Docker:** All Docker commands must be executed within the context of the `.admin/` directory. Target cleanups (`make clean` or similar) must incorporate `docker system prune -y` to maintain minimal disk usage.
* **Python:** Virtual environments are required for all Python utilities. Environments must be activated using the POSIX-compliant `.` (dot) operator (e.g., `. $(PY39)/bin/activate`). Do not use `source`.

### 2. Documentation & Formatting Rules
* **Cross-References:** Cross-reference markers MUST be strictly excluded from all markdown reports and Bill of Materials (BOM) outputs to prevent rendering artifacts.
* **Editor Standards:** Any documentation, script, or automated suggestion requiring command-line text editing must specify the use of `vi`.
* **Communication Tone:** All documentation, commit messages, script comments, and generated outputs must maintain a strictly technical and professional tone.
* **Metadata:** All recipe markdown files must begin with the standard YAML schema defined in `.admin/templates/recipe_skel.md`.

### 3. Auxiliary Tooling Workflow
* **BOM Generation:** Executed via `.admin/src/generate_bom.py`. The script scans top-level directories and outputs a sanitized aggregate list to the repository root.
* **AI Metadata Injection:** Executed via `.admin/src/populate_frontmatter.py`. The script utilizes the `google-genai` SDK to infer missing YAML data (prep time, cook time, tags) and parses `CREDITS.md` to inject correct authorship.