#!/usr/bin/env python3
"""Convert between PPTX and PDF using LibreOffice."""

import sys
import os
import shutil
import subprocess
import glob
from pathlib import Path


TARGET_EXT = {".pptx": "pdf", ".pdf": "pptx"}


def find_libreoffice() -> str:
    candidates = ["libreoffice", "soffice"]
    if sys.platform == "win32":
        candidates = [
            "soffice.exe",
            r"C:\Program Files\LibreOffice\program\soffice.exe",
            r"C:\Program Files (x86)\LibreOffice\program\soffice.exe",
        ]
    for c in candidates:
        found = shutil.which(c)
        if found:
            return found
    print("Error: LibreOffice not found. Install it from https://libreoffice.org", file=sys.stderr)
    sys.exit(1)


def get_default_dir() -> str:
    if sys.platform == "win32":
        return str(Path.home() / "Documents")
    docs = os.path.expanduser("~/Documents")
    if os.path.isdir(docs):
        return docs
    return os.path.dirname(os.path.abspath(".")) or "."


def resolve_output(input_path: str, output_name: str | None, output_dir: str | None) -> str:
    in_ext = os.path.splitext(input_path)[1].lower()
    out_ext = TARGET_EXT.get(in_ext, "pdf")

    out_dir = output_dir if output_dir else get_default_dir()
    out_name = output_name if output_name else os.path.splitext(os.path.basename(input_path))[0] + "." + out_ext

    if os.path.isabs(out_name):
        return out_name

    return os.path.join(out_dir, out_name)


def convert_single(input_path: str, output_path: str):
    input_path = os.path.abspath(input_path)
    output_path = os.path.abspath(output_path)
    output_dir = os.path.dirname(output_path)
    os.makedirs(output_dir, exist_ok=True)

    in_ext = os.path.splitext(input_path)[1].lower()
    out_ext = os.path.splitext(output_path)[1].lower().lstrip(".")

    if out_ext not in ("pdf", "pptx"):
        print(f"Error: unsupported output format: {out_ext}", file=sys.stderr)
        sys.exit(1)

    lo = find_libreoffice()

    convert_to = out_ext
    infilter = None
    if in_ext == ".pdf" and out_ext == "pptx":
        convert_to = "pptx:Impress Office Open XML"
        infilter = "impress_pdf_import"

    cmd = [lo, "--headless", "--convert-to", convert_to, "--outdir", output_dir]
    if infilter:
        cmd = [lo, "--headless", f"--infilter={infilter}", "--convert-to", convert_to, "--outdir", output_dir]
    cmd.append(input_path)

    subprocess.run(cmd, check=True, capture_output=True, text=True)

    default_out = os.path.join(output_dir, os.path.splitext(os.path.basename(input_path))[0] + "." + out_ext)
    if default_out != output_path:
        os.replace(default_out, output_path)


def convert_batch(input_paths: list[str], output_dir: str | None):
    in_ext = os.path.splitext(input_paths[0])[1].lower()
    out_ext = TARGET_EXT.get(in_ext, "pdf")

    for p in input_paths:
        if os.path.splitext(p)[1].lower() != in_ext:
            print("Error: mixed file types not supported", file=sys.stderr)
            sys.exit(1)

    abs_paths = [os.path.abspath(p) for p in input_paths]

    out_dir = os.path.abspath(output_dir) if output_dir else get_default_dir()
    os.makedirs(out_dir, exist_ok=True)

    lo = find_libreoffice()

    convert_to = out_ext
    infilter = None
    if in_ext == ".pdf" and out_ext == "pptx":
        convert_to = "pptx:Impress Office Open XML"
        infilter = "impress_pdf_import"

    cmd = [lo, "--headless", "--convert-to", convert_to, "--outdir", out_dir]
    if infilter:
        cmd = [lo, "--headless", f"--infilter={infilter}", "--convert-to", convert_to, "--outdir", out_dir]
    cmd.extend(abs_paths)

    subprocess.run(cmd, check=True, capture_output=True, text=True)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Convert between PPTX and PDF")
    parser.add_argument("inputs", nargs="+", help="Input file(s) (.pptx or .pdf)")
    parser.add_argument("output_dir", nargs="?", default=None, help="Output directory (default: ~/Documents)")
    parser.add_argument("-o", "--output", help="Output filename (only with single input)")
    parser.add_argument("--dpi", type=int, default=150, help="Rendering DPI (ignored, LibreOffice default used)")
    parser.add_argument("--delete", "-d", action="store_true", help="Delete original files after conversion")

    args = parser.parse_args()

    out_dir = args.output_dir
    remaining = list(args.inputs)
    if out_dir is None and len(remaining) > 1:
        last = remaining[-1]
        last_exp = os.path.expanduser(last)
        is_ext = os.path.splitext(last)[1].lower() in (".pptx", ".pdf")
        if not is_ext and (os.path.isdir(last_exp) or not glob.glob(last)):
            out_dir = last_exp
            remaining.pop()

    input_files = []
    for item in remaining:
        expanded = sorted(glob.glob(item))
        if not expanded:
            print(f"Error: no files match: {item}", file=sys.stderr)
            sys.exit(1)
        input_files.extend(expanded)

    for p in input_files:
        if not os.path.isfile(p):
            print(f"Error: not a file: {p}", file=sys.stderr)
            sys.exit(1)

        in_ext = os.path.splitext(p)[1].lower()
        if in_ext not in TARGET_EXT:
            print(f"Error: unsupported format: {in_ext} (use .pptx or .pdf)", file=sys.stderr)
            sys.exit(1)

    if args.output and len(input_files) > 1:
        print("Error: -o flag requires a single input file", file=sys.stderr)
        sys.exit(1)

    try:
        if len(input_files) == 1:
            output = resolve_output(input_files[0], args.output, out_dir)
            print(f"Converting: {input_files[0]}", file=sys.stderr)
            print(f"Output:     {output}", file=sys.stderr)
            convert_single(input_files[0], output)
        else:
            print(f"Converting {len(input_files)} file(s)...", file=sys.stderr)
            convert_batch(input_files, out_dir)
    except (subprocess.CalledProcessError, FileNotFoundError, OSError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if args.delete:
        for f in input_files:
            os.remove(f)
            print(f"Deleted: {f}", file=sys.stderr)


if __name__ == "__main__":
    main()
