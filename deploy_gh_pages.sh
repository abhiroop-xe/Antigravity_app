#!/bin/bash

# 1. Build the Nebula v1 web app (HTML renderer is lighter)
echo "Building Nebula v1 (Lightweight)..."
flutter build web --release --base-href "/Antigravity_app/" --web-renderer html

# 2. Initialize a git repo in the build folder
cd build/web
touch .nojekyll
git init
git add .
git commit -m "Deploy to GitHub Pages (Lightweight)"

# 3. Force push to the gh-pages branch
echo "Pushing to GitHub Pages..."
git push -f https://github.com/abhiroop-xe/Antigravity_app.git master:gh-pages

echo "Deployment complete! Nebula v1 should be live at https://abhiroop-xe.github.io/Antigravity_app/ soon."
