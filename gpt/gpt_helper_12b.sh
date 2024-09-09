#!/bin/bash

# Generate prompt for o1-preview model
# Copy pasted into prompt 12: https://chatgpt.com/share/6731f9a4-f378-8006-966a-7bb8b0bd84da

for f in ../app/lib/screens/theory_data.dart ../app/lib/screens/theory_tab.dart ../app/lib/screens/links_tab.dart ../app/lib/providers/data_provider.dart
do
  echo -e "Content of $f:\n\`\`\`"
  cat $f
  echo -e "\`\`\`\n"
done
