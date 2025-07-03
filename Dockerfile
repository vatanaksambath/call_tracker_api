FROM node:19.6.0-alpine
WORKDIR /app
COPY package.json ./
COPY package-lock.json ./
RUN npm i
COPY ./ ./
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "start:prod"]
