#!/bin/bash

set -e
echo "Deployment started"

# Set environment variables
PROJECT_PATH=${PROJECT_PATH:-"/usr/share/nginx/node"}
PM2_APP_NAME=${PM2_APP_NAME:-"app1"}  # Define your PM2 app name

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Use the desired Node.js version
nvm use 16  # This uses the default version. You can specify a version like: nvm use 14

# Navigate to the project directory
cd $PROJECT_PATH || exit

# Log Node.js version for reference
node -v

git pull origin main

# Install project dependencies
npm install --yes

# Restart the app with PM2 or start it if not running using the ecosystem file
pm2 restart ecosystem.config.js || pm2 start ecosystem.config.js

# Configure PM2 to start on boot
pm2 startup  # This generates the startup command for your system

# Get the generated startup command and run it
STARTUP_CMD=$(pm2 startup | grep 'sudo' | tail -1)
eval $STARTUP_CMD

# Save the current PM2 process list to be started after reboot
pm2 save

# Optional: Log deployment time or output
echo "Deployment completed at $(date)" >> deployment.log
