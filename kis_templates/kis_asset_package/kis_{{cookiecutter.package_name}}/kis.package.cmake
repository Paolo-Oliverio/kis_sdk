# In packages/kis_{{cookiecutter.package_name}}/kis.package.cmake

set(PACKAGE_NAME "kis_{{cookiecutter.package_name}}")
set(PACKAGE_VERSION "0.1.0")
set(PACKAGE_VERSION_MAJOR "0")
set(PACKAGE_TYPE "INTERFACE")
set(PACKAGE_DESCRIPTION "An Asset package.")

# Optional metadata for tooling and discovery
# PACKAGE_CATEGORY: short category string (e.g. "Assets", "UI", "Audio")
# set(PACKAGE_CATEGORY "Assets")

# PACKAGE_SEARCH_TAGS: a list of short, searchable tags useful for UI/search
# set(PACKAGE_SEARCH_TAGS
#   "textures"
#   "sprites"
# )

# ============================================================================
#                           PACKAGE CONSTRAINTS
# ============================================================================
# Use the new unified tag system OR legacy platform-specific fields.

#+ Simplified configuration for asset packages
#+ Asset packages usually don't affect ABI; most will keep the default ABI variant.
#+ Use these fields to opt into per-config artifacts if needed.
set(PACKAGE_ABI_VARIANT "DEFAULT")

# Optional: mark this asset package as belonging to a feature set (for discovery)
# set(PACKAGE_FEATURES
#     "editor"
# )

# Optional: if this asset package produces different artifacts per config,
# set PACKAGE_ABI_VARIANT to PER_CONFIG.
# The config suffix (e.g., "debug") comes from the global KIS_CONFIG_SUFFIX
# set by CMake presets, not from a per-package variable.

# Legacy platform-only fields (retained for backward compatibility)
# set(PACKAGE_PLATFORMS
#    "android"
# )

# ============================================================================
#                          PACKAGE DEPENDENCIES
# ============================================================================

# Asset packages may depend on other asset packages or libraries
# for validation, processing, or tooling.
#set(PACKAGE_DEPENDENCIES
#    "kis_asset_tools;https://github.com/your-org/kis_asset_tools.git;v1.0.0"
#)

# Third-party dependencies for asset processing
#set(PACKAGE_FIND_DEPENDENCIES ImageMagick)