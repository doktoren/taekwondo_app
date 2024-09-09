#!/bin/bash

# Generate prompt for o1-preview model
# https://chatgpt.com/share/66fe4e98-ec1c-8006-9bc9-6a98576c97ce

cat gpt_instructions_2.md
echo -e "\n\n"

echo -e "Content Amazon Lambda Function backend:\n\`\`\`"
cat ../lambda/main.py
echo -e "\`\`\`\n"

for f in ../app/lib/screens/* ../app/lib/services/* ../app/lib/main.dart
do
  echo -e "Content of $f:\n\`\`\`"
  cat $f
  echo -e "\`\`\`\n"
done
