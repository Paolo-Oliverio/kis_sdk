import os
import shutil


def copy_and_convert_cmake_to_txt(src_dir, dest_dir):
    # Ensure destination directory exists
    os.makedirs(dest_dir, exist_ok=True)

    for root, _, files in os.walk(src_dir):
        for file in files:
            src_path = os.path.join(root, file)
            # Get relative path from src_dir
            rel_path = os.path.relpath(root, src_dir)
            # Use directory name as prefix, if not root
            if rel_path == ".":
                prefix = ""
            else:
                # Replace os.sep with '_' for nested dirs
                prefix = rel_path.replace(os.sep, "_") + "_"
            dest_file = prefix + file + ".txt"
            dest_path = os.path.join(dest_dir, dest_file)

            # Check if destination exists
            if os.path.exists(dest_path):
                src_stat = os.stat(src_path)
                dest_stat = os.stat(dest_path)
                # Only overwrite if src is newer or larger
                if src_stat.st_mtime <= dest_stat.st_mtime and src_stat.st_size <= dest_stat.st_size:
                    print(f"Skipped (up-to-date): {dest_path}")
                    continue

            shutil.copy2(src_path, dest_path)
            print(f"Copied: {src_path} -> {dest_path}")


if __name__ == "__main__":
    src = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "..", "kis_build_system"))
    dest = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "cmake_dumps"))
    print(f"Source: {src}", f"Destination: {dest}")
    copy_and_convert_cmake_to_txt(src, dest)
    src = os.path.abspath(os.path.join(
    os.path.dirname(__file__), "..", "cmake"))
    dest = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "cmake_dumps"))
    print(f"Source: {src}", f"Destination: {dest}")
    copy_and_convert_cmake_to_txt(src, dest)