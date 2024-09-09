#!/bin/bash

# Generate prompt for o1-preview model
# https://chatgpt.com/share/66fe7e85-5294-8006-8a85-a0786105aa05

cat gpt_instructions_4.md
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
