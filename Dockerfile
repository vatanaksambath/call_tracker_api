FROM node:19.6.0-alpine
WORKDIR /app
COPY package.json ./
COPY package-lock.json ./
COPY node_modules ./
#RUN npm i
COPY ./ ./
RUN chmod +x ./node_modules/.bin/nest
RUN npm run build
EXPOSE 3000
#RUN npm run start:prod
CMD ["npm", "run", "start:prod"]