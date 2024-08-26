FROM node:20-slim AS build
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build & \
    npm run test