FROM node:18-alpine AS builder
WORKDIR /app
COPY apps/nextjs-app/package.json apps/nextjs-app/yarn.lock ./apps/nextjs-app/
RUN cd apps/nextjs-app && \
    yarn config set registry https://registry.yarnpkg.com && \
    yarn cache clean && \
    YARN_CACHE_FOLDER=/tmp/yarn_cache yarn install --production --frozen-lockfile --network-timeout 600000 || \
    (echo "Retrying yarn install" && yarn cache clean && YARN_CACHE_FOLDER=/tmp/yarn_cache yarn install --production --frozen-lockfile --network-timeout 600000) && \
    rm -rf /tmp/yarn_cache /usr/local/share/.cache/yarn /root/.cache
COPY . .
RUN cd apps/nextjs-app && yarn build && rm -rf /tmp/yarn_cache /usr/local/share/.cache/yarn /root/.cache

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/apps/nextjs-app ./
RUN yarn config set registry https://registry.yarnpkg.com && \
    yarn cache clean && \
    YARN_CACHE_FOLDER=/tmp/yarn_cache yarn install --production --network-timeout 600000 && \
    rm -rf /tmp/yarn_cache /usr/local/share/.cache/yarn /root/.cache
EXPOSE 3000
CMD ["yarn", "start"]
