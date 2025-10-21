# In packages/kis_{{cookiecutter.package_name}}/kis.package.cmake

set(PACKAGE_NAME "kis_{{cookiecutter.package_name}}")
set(PACKAGE_VERSION "0.1.0")
set(PACKAGE_VERSION_MAJOR "0")
{% if cookiecutter.library_type == "Library" %}
set(PACKAGE_TYPE "LIBRARY")
{% endif %}
{% if cookiecutter.library_type == "Interface" %}
set(PACKAGE_TYPE "INTERFACE")
{% endif %}
#set(PACKAGE_SUPPORTED_VARIANTS "")
set(PACKAGE_DESCRIPTION "A basic package.")

# Optional metadata for tooling and discovery
# PACKAGE_CATEGORY: short category string (e.g. "Rendering", "Core", "Tools")
# set(PACKAGE_CATEGORY "Core")

# PACKAGE_SEARCH_TAGS: a list of short, searchable tags useful for UI/search
# set(PACKAGE_SEARCH_TAGS
#   "render"
#   "graphics"
# )

# ============================================================================
#                           PACKAGE CONSTRAINTS
# ============================================================================
# Use the new unified tag system OR legacy platform-specific fields.
# The unified system supports platform, build mode, and feature tags.

{% if cookiecutter.library_type == "Library" %}
set(PACKAGE_ABI_VARIANT "ABI_INVARIANT")
{% endif %}