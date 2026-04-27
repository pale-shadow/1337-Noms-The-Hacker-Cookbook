# syntax=docker/dockerfile:1

FROM python:3.13-slim-bullseye

LABEL org.opencontainers.image.authors="nilknarf <franklin@dead10c5.org>"
LABEL org.opencontainers.image.source="https://github.com/DEAD10C5/1337-Noms-The-Hacker-Cookbook"
LABEL org.opencontainers.image.description="Ye Olde Hacker Cookbook"
LABEL org.opencontainers.image.licenses="CC BY-ND 4.0 DEED"

ENV DEBIAN_FRONTEND noninteractive
ADD . /app
WORKDIR /app/.admin

RUN \
  apt-get update; \
  apt-get install -y gnupg2 apt-utils;\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367;\
  apt-get -y autoremove;\
  apt-get install -y make git

# Python3 setup
RUN pwd;\
  pip install --upgrade pip