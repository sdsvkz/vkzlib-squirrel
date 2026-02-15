# MIT License
#
# Copyright (c) 2026 sdsvkz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import json
import os
import sys
from pathlib import Path
from typing import Iterable


def getSectionSeperator(symbol: str, length: int, embedded: str = "") -> str:
    if len(symbol) != 1:
        raise ValueError("Symbol must be a single character")
    
    if embedded == "":
        return symbol * length
    
    embedded = f" {embedded} "
    embedded_len = len(embedded)
    total_symbol_len = length - embedded_len
    front_symbol_len = total_symbol_len // 2
    back_symbol_len = front_symbol_len + total_symbol_len % 2
    
    return f"{symbol * front_symbol_len}{embedded}{symbol * back_symbol_len}"


SEPERATOR_LENGTH = 80


def build(
    resolved_root_dir: Path,
    resolved_setup_script_path: Path,
    resolved_exclude_paths: Iterable[Path],
    target_suffix: str,
    output_suffix: str,
):
    if not resolved_root_dir.is_dir():
        raise ValueError(f"`root` is not a directory: {resolved_root_dir}")

    # Read the content of the setup script
    if not resolved_setup_script_path.is_file():
        raise FileNotFoundError(f"Error: {resolved_setup_script_path} not found in {resolved_root_dir}.")
    
    setup_block = resolved_setup_script_path.read_text(encoding = 'utf-8')
    
    begin_generate_indicator = getSectionSeperator("#", SEPERATOR_LENGTH, f"BEGIN {resolved_setup_script_path.name}")
    end_generate_indicator = getSectionSeperator("#", SEPERATOR_LENGTH, f"END {resolved_setup_script_path.name}")

    # Filter out unnecessary paths
    resolved_exclude_paths = {p for p in exclude_paths if p.exists()}

    # Walk through the file structure
    for root, dirs, files in os.walk(resolved_root_dir, topdown = True):
        current_root = Path(root).resolve()
        
        # Directory Exclusion
        if any(current_root == ex for ex in resolved_exclude_paths):
            dirs[:] = [] # Stop os.walk from descending further
            continue
        
        for filename in files:
            if filename.endswith(target_suffix):
                input_path = current_root / filename
                
                # File Exclusion
                if any(input_path == ex for ex in resolved_exclude_paths):
                    continue
                
                # Determine output name (e.g., a.in.nut -> a.nut)
                output_path = input_path.with_name(filename[:-len(target_suffix)] + output_suffix)

                # Generate file
                original_content = input_path.read_text(encoding = 'utf-8')
                generated_content = (
                    f"{begin_generate_indicator}\n"
                    f"{setup_block}\n"
                    f"{end_generate_indicator}\n\n"
                    f"{original_content}"
                )
                output_path.write_text(generated_content, encoding = 'utf-8')
                print(f"Generated: {output_path}")


def ensureType(obj, t: type, errmsg: str):
    if not isinstance(obj, t):
        raise TypeError(errmsg)
    return obj


def ensurePropType(obj, prop_name: str, prop_type: type, default_value = None):
    return ensureType(
        obj.get(prop_name, default_value),
        prop_type,
        f"Wrong type of property `{prop_name}` from config file.")


usage = """
Usage: python build.py <config_path>

Configuration is a json file with following properties:

    root: string
    Path to the root directory for scanning, e.g. ".", "src/"

    setup: string
    Path to setup script, e.g. "setup/minimal.setup.nut", "../lib/vkzlib/setup/full.setup.nut"

    exclude?: string[]
    A list of path to exclude from scanning, e.g. ["setup/", "src/exclude.in.nut"]

    target_suffix?: string
    suffix of input files to be processed
    Defaults to ".in.nut"

    output_suffix?: string
    suffix of output files
    Defaults to ".nut"
    
! All path are relative to the directory of build configuration file
"""


if __name__ == "__main__":
    args = sys.argv[1:]
    argc = len(args)

    if (argc == 0):
        print(usage)
        exit()
    elif (argc > 1):
        raise ValueError("Too many arguments provided")
    
    config_path = Path(args[0]).resolve()
    
    if not config_path.is_file():
        raise FileNotFoundError(f"Error: {config_path} not found.")
    
    with open(config_path, 'r') as f:
        config = json.load(f)

    # Parsing properties
    processPath = lambda path: config_path.parent / Path(path)
    
    root_dir = processPath(ensurePropType(config, "root", str))
    setup_script_path = processPath(ensurePropType(config, "setup", str))
    exclude_paths = (
        processPath(ensureType(p, str, f"`exclude[{i}]` is not a string."))
        for i, p in enumerate(ensurePropType(config, "exclude", Iterable, set()))
    )
    target_suffix: str = ensurePropType(config, "target_suffix", str, ".in.nut")
    output_suffix: str = ensurePropType(config, "output_suffix", str, ".nut")
    
    # Start the process in the current directory
    build(
        root_dir,
        setup_script_path,
        exclude_paths,
        target_suffix,
        output_suffix,
    )