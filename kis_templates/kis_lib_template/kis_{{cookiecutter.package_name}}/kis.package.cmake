# In packages/kis_{{cookiecutter.package_name}}/kis.package.cmake

set(PACKAGE_NAME "kis_{{cookiecutter.package_name}}")
set(PACKAGE_VERSION "0.1.0")
set(PACKAGE_VERSION_MAJOR "0")
{% if cookiecutter.library_type == "Library" %}
set(PACKAGE_TYPE "STATIC")
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

# ============================================================================
# Simplified configuration (current system)
# Use these fields to declare how the package affects ABI and which
# configuration-specific variants it provides.
#
# PACKAGE_ABI_VARIANT: Controls whether the package has a single ABI
#   or per-config ABIs. Valid values: 
#      - PER_CONFIG   : (default) Installed different directories (e.g., lib/windows-x64-profiling/)
#                       The suffix comes from the global KIS_CONFIG_SUFFIX set by presets.
#     - ABI_INVARIANT : Single ABI shared across all configs 
#                       Installed to: lib/windows-x64/
#    
set(PACKAGE_ABI_VARIANT "PER_CONFIG ")  # or "ABI_INVARIANT" or omit for default

# PACKAGE_CUSTOM_VARIANTS: (PER_CONFIG packages only)
#   Define package-specific custom variants and their ABI compatibility.
#   Format: "variant_name:ABI_GROUP:Description"
#   The variant will be registered globally and can be used by other compatible packages.
#
#   Example:
#     set(PACKAGE_CUSTOM_VARIANTS "gpu-profile:RELEASE:GPU profiling instrumentation")
#     set(PACKAGE_SUPPORTED_VARIANTS "release;gpu-profile")
#   
#   Then build with: cmake --preset release -DKIS_CONFIG_SUFFIX=gpu-profile
# set(PACKAGE_CUSTOM_VARIANTS "")

# PACKAGE_FEATURES: Optional list of feature flags that the package
# provides or requires. These are for discovery and filtering only.
# They do NOT affect installation paths or ABI.
# set(PACKAGE_FEATURES
#    "profiling"
#    "tools"
# )

# Legacy platform-only fields (retained for backward compatibility)
# PACKAGE_PLATFORMS: List specific platforms this package supports
# set(PACKAGE_PLATFORMS
#    "windows"
#    "linux"
# )

# ============================================================================
#                          PACKAGE DEPENDENCIES
# ============================================================================

# Declare dependencies on other KIS packages.
# Format: "<package_name>;<repository_url>;<git_tag_or_branch>"
# set(PACKAGE_DEPENDENCIES
#    "kis_core;https://github.com/your-org/kis_core.git;v1.2.0"
#    "kis_rendering;https://github.com/your-org/kis_rendering.git;main"
#)

# Declare third-party dependencies managed via find_package()
#set(PACKAGE_FIND_DEPENDENCIES fmt spdlog)