#!/bin/bash

# Generate prompt for o1-preview model
# https://chatgpt.com/share/6731f9a4-f378-8006-966a-7bb8b0bd84da

cat gpt_instructions_12.md
echo -e "\n\n"

echo -e "Content Amazon Lambda Function backend:\n\`\`\`"
cat ../lambda/main.py
echo -e "\`\`\`\n"

for f in ../app/lib/screens/* ../app/lib/services/* ../app/lib/main.dart
do
  if [[ "$f" == "../app/lib/screens/theory_data.dart"
     || "$f" == "../app/lib/screens/theory_tab.dart"
     || "$f" == "../app/lib/screens/links_tab.dart" ]]
  then
    echo -e "Content of $f is not relevant and not shown. It does not depend on any data from the backend.\n"
  else
    echo -e "Content of $f:\n\`\`\`"
    cat $f
    echo -e "\`\`\`\n"
  fi
done
