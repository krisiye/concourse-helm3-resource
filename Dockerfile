FROM alpine/helm:3.4.2
LABEL maintainer "Yann David (@Typositoire) <davidyann88@gmail>"

RUN apk add --update --upgrade --no-cache jq bash curl git

ARG KUBERNETES_VERSION=1.18.2
ARG AWS_IAM_AUTHENTICATOR_VERSION=v0.5.2

RUN apk update && apk add \
	ca-certificates \
	groff \
	less \
	python \
	py-pip \
	&& rm -rf /var/cache/apk/* \
  && pip install pip --upgrade \
  && pip install awscli

# Download and install aws-iam-authenticator
RUN curl -s -L -o /usr/local/bin/aws-iam-authenticator "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_$(echo "$AWS_IAM_AUTHENTICATOR_VERSION" | tr -d v)_linux_amd64" && \
chmod +x /usr/local/bin/aws-iam-authenticator && \
aws-iam-authenticator version && \
rm -rf /var/lib/apt/lists/*


RUN curl -sL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl; \
  chmod +x /usr/local/bin/kubectl

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

ARG HELM_PLUGINS="https://github.com/helm/helm-2to3 https://github.com/databus23/helm-diff"
RUN for i in $(echo $HELM_PLUGINS | xargs -n1); do helm plugin install $i; done

RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
  install kustomize /usr/local/bin/kustomize

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
