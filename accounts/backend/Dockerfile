FROM node:latest

RUN mkdir -p /app/src

WORKDIR /app/src

COPY package.json .

RUN npm install

COPY . .

EXPOSE 8000

ENV DEV_GOOGLE_APPLICATION_CREDENTIALS=/app/data/firebase-adminsdk-credentials.json

CMD ["npm", "start"]