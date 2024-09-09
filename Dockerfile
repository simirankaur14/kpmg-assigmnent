# Use official Node.js
FROM node:8.6.0

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Copy files
COPY package.json .
COPY yarn.lock .
COPY index.js .

# Install dependencies
RUN yarn install

# Start app on port 8000
EXPOSE 8000
CMD node index.js
