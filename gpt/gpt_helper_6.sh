#!/bin/bash

# Generate prompt for o1-preview model
# https://chatgpt.com/share/66ffd136-0c84-8006-aa6e-b0e9f1032841

cat gpt_instructions_6.md
echo -e "\n\n"

echo -e "Content Amazon Lambda Function backend:\n\`\`\`"
cat ../lambda/main.py
echo -e "\`\`\`\n"

for f in ../app/lib/screens/* ../app/lib/services/* ../app/lib/main.dart
do
  if [[ "$f" == "../app/lib/screens/theory_data.dart"
     || "$f" == "../app/lib/screens/theory_tab.dart"
     || "$f" == "../app/lib/screens/links_tag.dart" ]]
  then
    echo -e "Content of $f is not relevant and not shown. It does not depend on any data from the backend.\n"
  else
    echo -e "Content of $f:\n\`\`\`"
    cat $f
    echo -e "\`\`\`\n"
  fi
done
