#!/bin/sh

docker build --tag libxml2-cve-2024-25062 .
docker run -t libxml2-cve-2024-25062