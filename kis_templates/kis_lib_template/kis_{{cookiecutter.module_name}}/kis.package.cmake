# In packages/kis_{{cookiecutter.module_name}}/kis.package.cmake

set(PACKAGE_NAME "kis_{{cookiecutter.module_name}}")
set(PACKAGE_VERSION "0.1.0")
set(PACKAGE_VERSION_MAJOR "0")
set(PACKAGE_DESCRIPTION "A basic package.")

# NEW: Declare dependencies on other KIS packages by name.
#set(PACKAGE_DEPENDENCIES
#   core_utils
#    rendering_api
#)

# NEW: Provide remote locations for dependencies that might be missing.
# Format: "<package_name>;<repository_url>;<git_tag_or_branch>"
#set(PACKAGE_REMOTES
#    core_utils;https://github.com/your-org/kis_core_utils.git;v1.2.0
#    rendering_api;https://github.com/your-org/kis_rendering_api.git;main
#)

#set(PACKAGE_FIND_DEPENDENCIES fmt spdlog)