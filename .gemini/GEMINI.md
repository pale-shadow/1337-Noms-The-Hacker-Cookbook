# Hacker Cookbook LLM Context (GEMINI.md)

This document provides context for AI agents assisting with the "1337-Noms-The-Hacker-Cookbook" project.

## Project Architecture
The project uses a hybrid build system to generate a culinary-themed technical "cookbook" in PDF format.

- **Admin Root:** Most maintenance and build logic resides in the `.admin/` directory. 
- **Documentation Engine:** The book is generated using LaTeX.
- **Build Automation:** Autotools (`autoconf`, `automake`) is used to manage the build lifecycle via `Makefile.am`.

## Key Components & Locations

### 1. Build Infrastructure (.admin/)
- **`.admin/Dockerfile`:** A Debian-based container environment containing all TeX Live dependencies and Python tools.
- **`.admin/Makefile.am`:** Defines targets for building the PDF (`make book`), managing Docker (`make docker`), and setting up Python environments.
- **`.admin/bin/generate_book.sh`:** The primary wrapper for `latexmk` and PDF generation.

### 2. LaTeX Configuration
- **`.admin/tex/preamble.tex`:** Contains global style definitions and package imports.
- **`ifmtarg.tex`:** Utility for checking empty macro arguments within the TeX engine.

### 3. Python Integration
- The project uses Python for auxiliary tooling.
- Always use the `$(PY39)` variable defined in the Makefile for virtual environments.
- Python activation should be performed using the `.` (source) command rather than `source` for POSIX compliance.

## Environment-Specific Instructions

### Debian/Ubuntu
Standard bootstrap involves installing `m4`, `autoconf`, and `gnupg2`.

### OpenBSD
The project includes specific support for OpenBSD. Setup requires:
- `pkg_add git-lfs`
- Configuration of `TEXMFHOME` to properly resolve local style files.

## Guidelines for LLM Assistance
- **Editor Preference:** When suggesting configuration changes or script edits, prioritize instructions compatible with `vi`.
- **Docker Usage:** Docker operations should be performed from the `.admin/` context. Use `docker-compose.yml` located in `.admin/` directly.
- **Cleanup:** Always include `docker system prune -y` logic in maintenance scripts to manage lab environment storage.
- **Compliance:** Ensure all generated documentation or code comments adhere to the `CC BY-ND 4.0 DEED` license where applicable.
