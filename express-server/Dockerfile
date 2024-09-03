# Use the official Node.js image from Docker Hub
FROM node:22-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the package.json and package-lock.json (if exists) to leverage Docker cache
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application files to the container
COPY . .

EXPOSE 8000

# Set the default command to run the application
CMD npm run start
