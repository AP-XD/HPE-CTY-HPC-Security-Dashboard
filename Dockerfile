# Use a Node.js base image
FROM node:14

# Create app directory
WORKDIR /app

# # Copy package files to app directory
# COPY package*.json ./

# # Install app dependencies
# RUN npm install

# Copy server application and data files to app directory
COPY server-combined.js ./
COPY trivy-cis-status.json ./
COPY kube-bench.json ./

# Expose ports
EXPOSE 7000
EXPOSE 7001

# Set default command to run server.js
CMD ["node", "server-combined.js"]
