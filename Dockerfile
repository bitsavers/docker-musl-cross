FROM amd64/alpine:3
LABEL maintainer="bitsaver <contact@bitsaver>"

ARG MUSL_CROSS_MAKE_GIT_TAG
ARG TRIPLE_TARGET

RUN apk update && apk upgrade \
    && apk add --no-cache \
        curl \
        rsync \
        sudo \
\
    && cd /tmp \
    && curl -sL4 --connect-timeout 5 --retry 5 --retry-delay 5 --retry-max-time 25 https://github.com/bitsavers/musl-cross-make/releases/download/${MUSL_CROSS_MAKE_GIT_TAG}/${TRIPLE_TARGET}-cross.tgz -o ${TRIPLE_TARGET}-cross.tgz \
    && tar -xf ${TRIPLE_TARGET}-cross.tgz \
    && rm ${TRIPLE_TARGET}-cross.tgz \
    && cd ${TRIPLE_TARGET}-cross \
        && rm -f $(find . -name "ld-musl-*.so.1") \
        && rm usr \
        && rsync --chown root:root --ignore-errors -rLaq . / || true \
        && cd .. \
    && rm -fr ${TRIPLE_TARGET}-cross \
    && cd /bin \
        && for file in "${TRIPLE_TARGET}-"*; do \
            mv ${file} $(echo "${file}" | sed -e "s/^${TRIPLE_TARGET}-//"); \
        done; \
        ln -sf gcc cc \
    && echo >> /etc/sudoers '%wheel ALL=(ALL) NOPASSWD:ALL' \
\
    && apk del \
        rsync
