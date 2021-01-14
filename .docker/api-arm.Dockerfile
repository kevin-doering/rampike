ARG APP_NAME

FROM arm64v8/node:14.15.4-alpine as buildContainer
ENV CYPRESS_INSTALL_BINARY=0
ARG APP_NAME
WORKDIR /rampike
COPY ./*.js ./
COPY ./*.json ./
COPY ./apps/$APP_NAME/ ./apps/$APP_NAME/
COPY ./libs/ ./libs/
RUN npm ci
RUN npm run nx build $APP_NAME -- --prod --optimization

FROM arm64v8/node:14.15.4-alpine
ARG APP_NAME
WORKDIR /dist/app
COPY --from=buildContainer /rampike/dist/apps/$APP_NAME/ /dist/app/
COPY --from=buildContainer /rampike/*.json /dist/app/
RUN npm install --only=production
EXPOSE 3333
CMD ["node", "main.js"]
