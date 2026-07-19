FROM mcr.microsoft.com/playwright:v1.61.0-jammy
RUN npm install -g netlify-cli serve
RUM apt update && apt install jq -y