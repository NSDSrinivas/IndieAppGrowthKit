#!/usr/bin/env python3
"""Extract one exact, dated release section from CHANGELOG.md."""

import re
import sys
from datetime import date
from pathlib import Path


# Match comments and top-level Markdown fences before looking for headings.
# A closing fence must use the same marker and be at least as long as the opener.
NON_HEADING_BLOCKS = re.compile(
    r"<!--.*?(?:-->|\Z)"
    r"|^ {0,3}(?:(?P<backticks>`{3,})[^`\n]*|(?P<tildes>~{3,})[^\n]*)(?:\n|\Z)"
    r"(?P<code>.*?)"
    r"(?:^ {0,3}(?(backticks)(?P=backticks)`*|(?P=tildes)~*)[ \t]*$|\Z)",
    re.DOTALL | re.MULTILINE,
)
STRUCTURAL_LINE = re.compile(
    r"[ \t]*(?:"
    r"#{1,6}(?:[ \t].*)?|(?:[-+*]|[0-9]{1,9}[.)]|>)[ \t]*"
    r"|(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,}"
    r"|\[[^\]]+\]:.*"
    r")?"
)
ATX_SECTION_HEADING = re.compile(r" {0,3}#{1,2}(?:[ \t].*)?")
SETEXT_UNDERLINE = re.compile(r" {0,3}(?:=+|-+)[ \t]*")
PARAGRAPH_LINE = re.compile(
    r" {0,3}(?!#{1,6}(?:[ \t]|$)|>|(?:[-+*]|[0-9]{1,9}[.)])(?:[ \t]|$))\S"
)
EMPTY_HTML = re.compile(
    r"<(?P<tag>[a-z][a-z0-9-]*)(?:[ \t]+[^<>\n]*)?>\s*</(?P=tag)[ \t]*>"
    r"|<(?:br|hr|wbr)[ \t]*/?>",
    re.IGNORECASE,
)


def section_headings(text):
    paragraph_start = None
    for line in re.finditer(r"^.*$", text, re.MULTILINE):
        content = line.group()
        if ATX_SECTION_HEADING.fullmatch(content):
            yield line
        elif SETEXT_UNDERLINE.fullmatch(content):
            if paragraph_start is not None:
                yield paragraph_start
        elif PARAGRAPH_LINE.match(content):
            if paragraph_start is None:
                paragraph_start = line
            continue
        paragraph_start = None


def extract(text, tag):
    if not re.fullmatch(r"v(?:0|[1-9][0-9]*)(?:\.(?:0|[1-9][0-9]*)){2}", tag):
        raise ValueError("Expected a stable vX.Y.Z tag")

    version = re.escape(tag[1:])
    code_blocks = []

    def mask_block(block):
        if (code := block.group("code")) and code.strip():
            code_blocks.append(block.start())
        # Preserve offsets so extraction returns the original Markdown.
        return re.sub(r"[^\n]", " ", block.group())

    visible_text = NON_HEADING_BLOCKS.sub(mask_block, text)
    headings = list(section_headings(visible_text))
    version_heading = re.compile(r" {0,3}##[ \t]+\[" + version + r"(?=\]|[ \t]|$)")
    matches = [index for index, heading in enumerate(headings) if version_heading.match(heading.group())]
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one changelog section for {tag}")

    index = matches[0]
    heading = headings[index]
    dated_heading = re.fullmatch(
        r"## \[" + version + r"\] - ([0-9]{4}-[0-9]{2}-[0-9]{2})", heading.group()
    )
    if dated_heading is None:
        raise ValueError(f"Expected heading '## [{tag[1:]}] - YYYY-MM-DD'")
    try:
        date.fromisoformat(dated_heading.group(1))
    except ValueError as error:
        raise ValueError(f"Invalid changelog date for {tag}: {dated_heading.group(1)}") from error

    end = headings[index + 1].start() if index + 1 < len(headings) else len(text)
    visible_notes = EMPTY_HTML.sub("", visible_text[heading.end():end])
    has_prose = any(not STRUCTURAL_LINE.fullmatch(line) for line in visible_notes.splitlines())
    has_code = any(heading.end() <= start < end for start in code_blocks)
    if not (has_prose or has_code):
        raise ValueError(f"Release notes for {tag} are empty")
    return text[heading.end():end].strip()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: python3 scripts/release_notes.py vX.Y.Z")
    try:
        print(extract(Path("CHANGELOG.md").read_text(encoding="utf-8"), sys.argv[1]))
    except (ValueError, OSError) as error:
        sys.exit(str(error))
