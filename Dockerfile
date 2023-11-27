# To create an image for a version of ruby, run e.g.:

# docker build -t udi278 --build-arg ruby_version=2.7.8 --build-arg activerecord_version=5.2 .
# docker run --name udc278 -dit udi278
# docker exec -it udc278 bash --login
# docker stop udc278 && docker remove udc278

# (Any bundler_version is okay as long as its required_ruby_version is not >= 3.0.0.)

ARG ruby_version=3.1.2
ARG activerecord_version=7.0
ARG bundler_version=2.4.22

FROM ruby:${ruby_version}-bullseye

ARG ruby_version
ARG activerecord_version
ARG bundler_version

SHELL ["/bin/bash", "-c"]
ENV WORKDIR=/app
WORKDIR ${WORKDIR}
RUN apt update && \
  apt upgrade -qy && \
  apt install -qy default-mysql-client postgresql-client libyaml-dev git less procps vim && \
  rm -rf /var/lib/apt/lists/*

ENV BUNDLE_GEMFILE="${WORKDIR}/gemfiles/activerecord_${activerecord_version}.gemfile"

RUN gem install -v 2.4.22 bundler && \
  bundle config --local build.mysql2 -- $(ruby -r rbconfig -e 'puts RbConfig::CONFIG["configure_args"]' | xargs -n1 | grep with-openssl-dir)

ADD . ${WORKDIR}
RUN bundle install
