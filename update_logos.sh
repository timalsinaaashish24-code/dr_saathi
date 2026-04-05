#!/bin/bash

# Script to update Dr. Saathi logo across all platforms
# Usage: ./update_logos.sh <path_to_new_logo.png>

if [ -z "$1" ]; then
    echo "Usage: ./update_logos.sh <path_to_new_logo.png>"
    echo "Example: ./update_logos.sh ~/Downloads/dr_saathi_logo.png"
    exit 1
fi

LOGO_PATH="$1"

if [ ! -f "$LOGO_PATH" ]; then
    echo "Error: Logo file not found at $LOGO_PATH"
    exit 1
fi

echo "📱 Updating Dr. Saathi logo across all apps..."
echo ""

# Base directory
BASE_DIR="/Users/test/dr_saathi/dr_saathi"

# Patient App
echo "✅ Copying to Patient App..."
cp "$LOGO_PATH" "$BASE_DIR/assets/images/app_icon.png"

# Doctor Portal
echo "✅ Copying to Doctor Portal..."
cp "$LOGO_PATH" "$BASE_DIR/dr_saathi_doctor_portal/assets/images/app_icon.png"

# Admin App
echo "✅ Copying to Admin App..."
cp "$LOGO_PATH" "$BASE_DIR/dr_saathi_admin/assets/images/app_icon.png"

echo ""
echo "🎉 Logo updated successfully in all three apps!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter clean' in each app directory"
echo "2. Run 'flutter pub get' in each app directory"
echo "3. Run 'flutter run' to see the new logo"
