#!/bin/bash

# Generate prompt for o1-preview model
# https://chatgpt.com/share/66ffc8a7-11a4-8006-a981-fe229fc8a7a5

cat gpt_instructions_5.md
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
