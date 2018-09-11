FROM resin/raspberry-pi-alpine-node:8
LABEL maintainer murufon

ENV APP_VERSION v3.2.2
ENV APP_DIR /opt/growi

# update tar for '--strip-components' option
RUN apk add --no-cache --update tar
# download GROWI archive from Github
RUN apk add --no-cache --virtual .dl-deps curl \
    && mkdir -p ${APP_DIR} \
    && curl -SL https://github.com/weseek/growi/archive/${APP_VERSION}.tar.gz \
        | tar -xz -C ${APP_DIR} --strip-components 1 \
    && apk del .dl-deps

WORKDIR ${APP_DIR}

# setup
RUN apk add --no-cache --virtual .build-deps git \
    && yarn \
    # install official plugins
    && yarn add growi-plugin-lsx growi-plugin-pukiwiki-like-linker \
    && npm run build:prod \
    # shrink dependencies for production
    && yarn install --production \
    && yarn cache clean \
    && apk del .build-deps

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

VOLUME /data
EXPOSE 3000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["npm", "run", "server:prod"]

ENV APP_DIR /opt/growi

# install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN apk add --no-cache --virtual .dl-deps curl \
    && curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-armhf-$DOCKERIZE_VERSION.tar.gz \
        | tar -xz -C /usr/local/bin \
    && apk del .dl-deps

WORKDIR ${APP_DIR}

# install plugins if necessary
# ;;
# ;; NOTE: In GROWI v3 and later,
# ;;       2 of official plugins (growi-plugin-lsx and growi-plugin-pukiwiki-like-linker)
# ;;       are now included in this image.
# ;;       Therefore you will not need following lines except when you install third-party plugins.
# ;;
#RUN echo "install plugins" \
#  && yarn add \
#      growi-plugin-XXX \
#      growi-plugin-YYY \
#  && echo "done."
# you must rebuild if install plugin at least one
# RUN npm run build:prod
