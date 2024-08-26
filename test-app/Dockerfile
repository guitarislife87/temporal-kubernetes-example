FROM node:20-bullseye-slim AS build
WORKDIR /app

RUN apt-get update \
    && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build & \
    npm run test