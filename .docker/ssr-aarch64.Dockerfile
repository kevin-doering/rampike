ARG RELEASE
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
RUN npm run nx run $APP_NAME:server:production

FROM arm64v8/node:14.15.4-alpine
ARG RELEASE
ARG APP_NAME
ENV PORT=4000
ENV VERSION=$RELEASE
COPY --from=buildContainer /rampike/dist/apps/$APP_NAME/browser/ /dist/apps/$APP_NAME/browser/
COPY --from=buildContainer /rampike/dist/apps/$APP_NAME/server/ /dist/apps/server/
EXPOSE $PORT
CMD ["node", "dist/apps/server/main.js"]
