import os
import shutil

# This script runs *after* the project folder has been created.
# 1. Get the value of the 'library_type' variable from cookiecutter.json
library_type = '{{ cookiecutter.library_type }}'

# 2. If the user chose 'Interface', we don't need the 'src' directory.
if library_type == 'Interface':
    #print(f"Library type is '{library_type}'. Removing 'src' directory...")
    
    # The path to the 'src' directory to be removed.
    # Note: This script runs from the root of the newly created project folder.
    src_directory_path = os.path.join('main', 'src')
    
    # Use shutil.rmtree to safely delete the directory and its contents.
    if os.path.exists(src_directory_path):
        shutil.rmtree(src_directory_path)
        #print(f"Removed directory: {src_directory_path}")
    else:
        print("Warning: 'src' directory not found, nothing to remove.")
#else:
#    print(f"Library type is '{library_type}'. Keeping 'src' directory.")