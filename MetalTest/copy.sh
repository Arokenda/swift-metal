#!/bin/sh

# Copy Metal shader files (with extension ".metal") to the compiled app bundle.
find "${SRCROOT}" -name "*.metal" -type f -exec cp {} "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app" \;

# Copy other resource files to the compiled app bundle as needed.
# ...
