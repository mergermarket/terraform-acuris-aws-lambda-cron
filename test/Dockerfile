FROM python:3-alpine
COPY requirements.txt .

ENV TERRAFORM_VERSION=0.13.7
ENV TERRAFORM_ZIP=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV TERRAFORM_SUM=4a52886e019b4fdad2439da5ff43388bbcc6cce9784fde32c53dcd0e28ca9957

RUN apk add -U ca-certificates curl && \
    cd /tmp && \
    curl -fsSLO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP} && \
    echo "${TERRAFORM_SUM}  /tmp/${TERRAFORM_ZIP}" | sha256sum -c - && \
    unzip /tmp/${TERRAFORM_ZIP} -d /usr/bin && \
    rm -rf /tmp/* /var/cache/apk/* /var/tmp/*

RUN pip install --no-cache-dir -r requirements.txt
ADD infra /infra

