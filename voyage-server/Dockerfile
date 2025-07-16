# Use Node.js LTS image
FROM node:20

# Set working directory
WORKDIR /src

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port (match your config, e.g., 3000)
EXPOSE 3000

# Start the app
CMD ["npm", "start"]