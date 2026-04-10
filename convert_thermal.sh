#!/bin/bash
# =============================================================================
# convert_thermal.sh
# Converts DJI M3T thermal JPEGs (*_T.JPG) to GeoTIFFs on macOS using Docker.
#
# Usage:
#   ./convert_thermal.sh <path-to-folder-with-thermal-jpgs>
#
# Example:
#   ./convert_thermal.sh ~/Desktop/my_flight_images
#
# Output:
#   A "tiff/" subfolder will be created inside your images folder.
#
# Requirements:
#   - Docker Desktop must be installed and running
#   - The rjpeg2tiff folder must be in the same directory as this script
# =============================================================================

set -e

# --- Check arguments ---------------------------------------------------------
if [ -z "$1" ]; then
    echo ""
    echo "  Usage: ./convert_thermal.sh <path-to-folder-with-thermal-jpgs>"
    echo ""
    echo "  Example: ./convert_thermal.sh ~/Desktop/my_flight_images"
    echo ""
    exit 1
fi

IMAGES_DIR=$(cd "$1" && pwd)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TOOLS_DIR="$SCRIPT_DIR/rjpeg2tiff"

# --- Sanity checks -----------------------------------------------------------
if [ ! -d "$IMAGES_DIR" ]; then
    echo "ERROR: Images folder not found: $IMAGES_DIR"
    exit 1
fi

if [ ! -d "$TOOLS_DIR" ]; then
    echo "ERROR: rjpeg2tiff folder not found next to this script."
    echo "       Expected at: $TOOLS_DIR"
    exit 1
fi

# Check Docker is available and running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running."
    echo "       Please open Docker Desktop and wait for it to start, then try again."
    exit 1
fi

# Count thermal images
THERMAL_COUNT=$(find "$IMAGES_DIR" -maxdepth 1 -name "*_T.JPG" -o -name "*_T.jpg" | wc -l | tr -d ' ')
if [ "$THERMAL_COUNT" -eq 0 ]; then
    echo "WARNING: No thermal images (*_T.JPG) found in: $IMAGES_DIR"
    echo "         Make sure your images end in _T.JPG"
    exit 1
fi

echo ""
echo "  Thermal images found : $THERMAL_COUNT"
echo "  Images folder        : $IMAGES_DIR"
echo "  Tools folder         : $TOOLS_DIR"
echo "  Output               : $IMAGES_DIR/tiff/"
echo ""
echo "  Starting conversion via Docker..."
echo ""

# --- Run conversion in a Linux Docker container ------------------------------
docker run --rm \
    --platform linux/amd64 \
    -v "$TOOLS_DIR":/tools \
    -v "$IMAGES_DIR":/images \
    --workdir /images \
    ubuntu:22.04 \
    bash -c '
        set -e

        # Install Perl (needed by exiftool)
        apt-get update -qq && apt-get install -y -qq perl libgomp1 > /dev/null 2>&1

        chmod +x /tools/rjpeg2tiff /tools/dji_irp /tools/raw2tiff /tools/exiftool

        # Find all thermal JPEGs
        FILES=$(find /images -maxdepth 1 \( -name "*_T.JPG" -o -name "*_T.jpg" \))

        if [ -z "$FILES" ]; then
            echo "No _T.JPG files found in /images"
            exit 1
        fi

        /tools/rjpeg2tiff $FILES
    '

echo ""
echo "  Done! Your TIFF files are in:"
echo "  $IMAGES_DIR/tiff/"
echo ""
