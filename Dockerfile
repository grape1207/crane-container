ARG CRANE_GO_VERSION=1.16

FROM registry.hub.docker.com/bitnami/git AS git
WORKDIR /src
RUN git clone https://github.com/konveyor/crane.git

FROM registry.hub.docker.com/library/golang:${CRANE_GO_VERSION} AS crane-build
COPY --from=git /src/ .
RUN cd crane \
  && go build -o crane main.go \
  && mv crane /usr/local/bin/

FROM registry.hub.docker.com/library/busybox AS oc-build
RUN wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz \
 && tar -xzf openshift-client-linux.tar.gz \
 && mkdir -p /usr/local/bin \
 && mv kubectl oc /usr/local/bin/

FROM registry.hub.docker.com/library/alpine AS final
LABEL maintainer="bbergen@redhat.com"
VOLUME [ "/root/.kube", "/data" ]
ENV EXPORT_DIR=crane-export
ENV CRANE_ADDITIONAL_OPTIONS=
RUN apk add libc6-compat
COPY --from=crane-build /usr/local/bin/crane /usr/local/bin/
COPY --from=oc-build /usr/local/bin/oc /usr/local/bin/kubectl /usr/local/bin/
WORKDIR /app
COPY entrypoint.sh .
ENTRYPOINT [ "/app/entrypoint.sh" ]