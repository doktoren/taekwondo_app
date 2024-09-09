#!/bin/bash

# Generate prompt for o1-preview model
# Last answer made it worse so I didn't include those changes
# https://chatgpt.com/share/66fe5b7f-03d8-8006-b34f-c4299507a5f9

cat gpt_instructions_3.md
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
