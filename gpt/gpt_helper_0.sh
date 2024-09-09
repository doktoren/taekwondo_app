#!/bin/bash

# Generate prompt for o1-preview model

cat gpt_instructions_0.md
echo -e "\n\n"

echo -e "Content of main.py:\n\`\`\`"
cat ../lambda/main.py
echo -e "\`\`\`\n"
