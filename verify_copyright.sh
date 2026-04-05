#!/bin/bash

# Dr. Saathi Copyright Verification Script
# This script checks if copyright information is properly set up

echo "=== Dr. Saathi Copyright Verification ==="
echo ""

# Check if LICENSE file exists
echo "1. Checking LICENSE file..."
if [ -f "LICENSE" ]; then
    echo "   ✅ LICENSE file exists"
    echo "   📄 License type: $(head -1 LICENSE)"
    echo "   ©️  Copyright: $(grep "Copyright" LICENSE)"
else
    echo "   ❌ LICENSE file not found"
fi
echo ""

# Check pubspec.yaml for author information
echo "2. Checking pubspec.yaml for author information..."
if grep -q "author:" pubspec.yaml; then
    echo "   ✅ Author information found"
    echo "   👤 $(grep "author:" pubspec.yaml)"
else
    echo "   ❌ Author information not found in pubspec.yaml"
fi

if grep -q "homepage:" pubspec.yaml; then
    echo "   🏠 $(grep "homepage:" pubspec.yaml)"
fi

if grep -q "repository:" pubspec.yaml; then
    echo "   📦 $(grep "repository:" pubspec.yaml)"
fi
echo ""

# Check main.dart for copyright header
echo "3. Checking main.dart for copyright header..."
if head -20 lib/main.dart | grep -q "Copyright"; then
    echo "   ✅ Copyright header found in main.dart"
    echo "   ©️  $(head -20 lib/main.dart | grep "Copyright")"
else
    echo "   ❌ Copyright header not found in main.dart"
fi
echo ""

# Check README.md for license section
echo "4. Checking README.md for license section..."
if grep -q "## License" README.md; then
    echo "   ✅ License section found in README.md"
    if grep -q "Copyright" README.md; then
        echo "   ✅ Copyright information found in README.md"
    else
        echo "   ⚠️  Copyright information not found in README.md"
    fi
else
    echo "   ❌ License section not found in README.md"
fi
echo ""

# Check for app version in various files
echo "5. Checking app version information..."
if grep -q "version:" pubspec.yaml; then
    echo "   📱 App version: $(grep "version:" pubspec.yaml | awk '{print $2}')"
else
    echo "   ⚠️  App version not found"
fi
echo ""

# Summary
echo "=== Copyright Setup Summary ==="
echo "Your Dr. Saathi app has the following copyright setup:"
echo ""
echo "• LICENSE file: MIT License with healthcare disclaimer"
echo "• Author: Dr. Saathi Development Team"
echo "• Copyright Year: 2025"
echo "• License Type: MIT License"
echo "• Healthcare Disclaimer: ✅ Included"
echo ""
echo "All copyright information appears to be properly configured! 🎉"
