FROM hashicorp/terraform:1.5 AS terraform

FROM python:3-alpine
COPY --from=terraform /bin/terraform /usr/bin/terraform
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

