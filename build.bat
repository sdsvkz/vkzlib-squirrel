@echo off

cd /D "%~dp0"

set build_script_file=build.py

echo "Building setup scripts..."
python %build_script_file% setup.build.json

echo "Building vkzlib..."
python %build_script_file% vkzlib.build.json
