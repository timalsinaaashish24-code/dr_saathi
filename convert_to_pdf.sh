#!/bin/bash

# Script to convert compliance document to PDF
# Usage: ./convert_to_pdf.sh

echo "Dr. Saathi - Compliance Document PDF Converter"
echo "=============================================="
echo ""

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc is not installed."
    echo ""
    echo "To install pandoc on macOS:"
    echo "  brew install pandoc"
    echo "  brew install --cask wkhtmltopdf"
    echo ""
    echo "Alternative methods:"
    echo "1. Online converter: https://www.markdowntopdf.com/"
    echo "2. VSCode extension: 'Markdown PDF'"
    exit 1
fi

echo "✅ Pandoc found!"
echo ""

# Convert the document
echo "Converting COMPLIANCE_REQUIREMENTS_NEPAL.md to PDF..."
pandoc COMPLIANCE_REQUIREMENTS_NEPAL.md \
    -o COMPLIANCE_REQUIREMENTS_NEPAL.pdf \
    --pdf-engine=wkhtmltopdf \
    -V geometry:margin=1in \
    -V papersize:a4 \
    --toc \
    --toc-depth=3 \
    -V colorlinks=true \
    -V linkcolor=blue \
    -V urlcolor=blue

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS!"
    echo "PDF created: COMPLIANCE_REQUIREMENTS_NEPAL.pdf"
    echo ""
    echo "Opening PDF..."
    open COMPLIANCE_REQUIREMENTS_NEPAL.pdf 2>/dev/null || echo "PDF created but unable to auto-open. Please open manually."
else
    echo ""
    echo "❌ ERROR: Conversion failed."
    echo ""
    echo "Please try one of these alternatives:"
    echo "1. Online: https://www.markdowntopdf.com/"
    echo "2. Copy content to Google Docs and export as PDF"
    echo "3. Use VSCode with 'Markdown PDF' extension"
fi
