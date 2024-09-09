#!/bin/bash

# Generate prompt for o1-preview model
# https://chatgpt.com/share/6704f21c-d064-8006-b5f9-f110c598db72
# https://chatgpt.com/share/6704f233-3be0-8006-b446-04d3ba6c0f88

cat gpt_instructions_10.md
echo -e "\n\n"

echo -e "Content Amazon Lambda Function backend:\n\`\`\`"
cat ../lambda/main.py
echo -e "\`\`\`\n"

for f in ../app/lib/screens/* ../app/lib/services/* ../app/lib/main.dart
do
  if [[ "$f" == "../app/lib/screens/theory_data.dart" ]]
  then
    echo -e "Content of ../app/lib/screens/theory_data.dart:\n\`\`\`"
    cat ./theory_data_example.dart
    echo -e "\`\`\`\n"
  else
    echo -e "Content of $f:\n\`\`\`"
    cat $f
    echo -e "\`\`\`\n"
  fi
done
