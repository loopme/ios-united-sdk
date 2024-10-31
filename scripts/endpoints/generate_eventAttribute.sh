#!/bin/bash

# Check if telemetry_specs.yml exists
if [ ! -f "telemetry_specs.yml" ]; then
  echo "Error: telemetry_specs.yml not found in the current directory."
  exit 1
fi

# Check if yq is installed
if ! command -v yq &> /dev/null
then
    echo "Error: yq is not installed. Please install yq to proceed."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p output

# Remove existing output files if they exist
if [ -f "output/EventAttribute.swift" ]; then
  rm "output/EventAttribute.swift"
fi

if [ -f "output/EventAttribute.kt" ]; then
  rm "output/EventAttribute.kt"
fi

# Extract property names using yq
property_names=$(yq e '.paths."/".post.requestBody.content."application/json".schema.properties | keys' telemetry_specs.yml)

# Clean up the property names
property_names=$(echo "$property_names" | sed 's/- //g')

# Generate Swift enum
swift_enum="enum EventAttribute: String {\n"
while IFS= read -r prop; do
    swift_enum+="    case $prop = \"$prop\"\n"
done <<< "$property_names"
swift_enum+="}"

# Generate Kotlin enum
kotlin_enum="enum class EventAttribute(val value: String) {\n"
while IFS= read -r prop; do
    upper_prop=$(echo "$prop" | tr '[:lower:]' '[:upper:]')
    kotlin_enum+="    $upper_prop(\"$prop\"),\n"
done <<< "$property_names"
kotlin_enum=$(echo "$kotlin_enum" | sed '$ s/,$//') # Remove the last comma
kotlin_enum+="\n}"

# Save the enums to files
echo "$swift_enum" > output/EventAttribute.swift
echo "$kotlin_enum" > output/EventAttribute.kt

echo "Generated EventAttribute.swift and EventAttribute.kt in the output folder."
