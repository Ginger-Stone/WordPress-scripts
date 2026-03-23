#!/bin/bash

# =============================================================
# WordPress Plugin Packager (Include-Only, Production Ready)
# -------------------------------------------------------------
# This script creates a clean, installable ZIP archive of a
# WordPress plugin using an allowlist (include list).
#
# What it does:
# - Copies only explicitly allowed files/directories
# - Installs Composer dependencies in production mode (--no-dev)
# - Optimizes autoloading for performance
# - Shows a verification list of files to be packaged
# - Prompts for confirmation before creating the ZIP
#
# Usage:
# chmod +x zip-plugin.sh
# ./zip-plugin.sh <plugin_path> [output_dir]
#
# Example:
# ./zip-plugin.sh /path/to/my-plugin /path/to/output
# =============================================================

set -e

PLUGIN_PATH=$1
OUTPUT_DIR=${2:-$(pwd)}

if [ -z "$PLUGIN_PATH" ]; then
  echo "Usage: $0 <plugin_path> [output_dir]"
  exit 1
fi

PLUGIN_PATH=$(realpath "$PLUGIN_PATH")
PLUGIN_NAME=$(basename "$PLUGIN_PATH")
TEMP_DIR="/tmp/${PLUGIN_NAME}_build"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ZIP_NAME="${PLUGIN_NAME}_${TIMESTAMP}.zip"

echo "📦 Preparing plugin package: $PLUGIN_NAME"

# =========================
# 📋 INCLUDE LIST
# =========================
INCLUDE_PATHS=(
  "*.php"
  "readme.txt"
  "assets"
  "build"
  "images"
  "includes"
  "src"
  "vendor"
  "composer.json"
  "composer.lock"
  "LICENSE"
  ""
)

# =========================
# 🔍 PREVIEW FILES
# =========================
echo "\n🔍 Files that will be included:" 
cd "$PLUGIN_PATH"

PREVIEW_LIST=()

for path in "${INCLUDE_PATHS[@]}"; do
  MATCHES=$(compgen -G "$path" || true)
  for match in $MATCHES; do
    PREVIEW_LIST+=("$match")
  done
done

if [ ${#PREVIEW_LIST[@]} -eq 0 ]; then
  echo "❌ No files matched the include list."
  exit 1
fi

for item in "${PREVIEW_LIST[@]}"; do
  echo " - $item"
done

# =========================
# ❗ CONFIRMATION
# =========================
echo ""
read -p "Proceed with packaging these files? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "❌ Packaging cancelled."
  exit 0
fi

# =========================
# 📁 COPY FILES
# =========================
echo "\n📁 Copying files..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/$PLUGIN_NAME"

for path in "${INCLUDE_PATHS[@]}"; do
  if compgen -G "$path" > /dev/null; then
    rsync -av "$path" "$TEMP_DIR/$PLUGIN_NAME/" 2>/dev/null || true
  fi
done

cd "$TEMP_DIR/$PLUGIN_NAME"

# =========================
# 🔧 COMPOSER OPTIMIZATION
# =========================
if [ -f "composer.json" ]; then
  echo "⚙️ Installing Composer dependencies (production)..."

  composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress

  composer dump-autoload -o
fi

# =========================
# 🗜️ CREATE ZIP
# =========================
echo "🗜️ Creating zip..."
cd "$TEMP_DIR"
zip -r "$ZIP_NAME" "$PLUGIN_NAME" > /dev/null

mv "$ZIP_NAME" "$OUTPUT_DIR"

# Cleanup
rm -rf "$TEMP_DIR"

echo "\n✅ Done!"
echo "📍 Output: $OUTPUT_DIR/$ZIP_NAME"

