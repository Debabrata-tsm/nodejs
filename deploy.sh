#!/bin/bash

# Set environment variables
PROJECT_PATH=${PROJECT_PATH:-"/usr/share/nginx/node"}
PM2_APP_NAME=${PM2_APP_NAME:-"app1"}  # Define your PM2 app name

# Navigate to the project directory
cd $PROJECT_PATH || exit

# Create ecosystem.config.js file
cat <<EOL > ecosystem.config.js
module.exports = {
  apps: [{
    name: "$PM2_APP_NAME",
    script: "./app.js",
    env: {
      PORT: 3005  # Define your port here
    },
  }]
}
EOL

# Log Node.js version for reference
node -v

# Install project dependencies
npm install

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
