FROM node:22.0.0
WORKDIR /app
COPY package.json ./
COPY package-lock.json ./
RUN npm i
COPY ./ ./
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "start:prod"]
