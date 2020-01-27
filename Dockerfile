FROM lsiobase/alpine:3.11
COPY . /app
RUN rm -R /app/.s6 && \
    apk add --no-cache nodejs npm && \
    cd /app && npm ci && npm run build && rm -R /app/node_modules && npm ci --production && \
    rm -R /app/src && \
    find /app | grep -v 'node_modules/'

FROM lsiobase/alpine:3.11
COPY . /app
RUN \
    apk add --no-cache \
      nodejs \
      redis curl
COPY .s6/ /
COPY --from=0 /app /app

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /usr/bin/curl -s -f http://localhost:${PORT:-8080}/api/status || exit 1
