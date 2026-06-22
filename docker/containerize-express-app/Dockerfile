FROM node:latest

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

RUN npm ci

COPY . . 

ENV PORT=5000


CMD ["node", "src/index.js"]