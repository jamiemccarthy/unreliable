# To create an image for a version of ruby, run e.g.:

# docker build -t udi278 --build-arg ruby_version=2.7.8 --build-arg activerecord_version=5.2 .
# docker run --name udc278 -dit udi278
# docker exec -it udc278 bash --login
# docker stop udc278 && docker remove udc278

# (Any bundler_version is okay as long as its required_ruby_version is not >= 3.0.0.)

FROM debian:bookworm
SHELL ["/bin/bash", "-c"]
ENV WORKDIR=/app
WORKDIR ${WORKDIR}
RUN apt update && \
  apt upgrade -qy && \
  apt install -qy default-mysql-client postgresql-client libyaml-dev git less procps vim && \
  apt install -qy rbenv && \
  rm -rf /var/lib/apt/lists/*

ARG ruby_version=3.1.2
ARG activerecord_version=7.0
ARG bundler_version=2.4.22
ENV BUNDLE_GEMFILE="${WORKDIR}/gemfiles/activerecord_${activerecord_version}.gemfile"

# We install rbenv, which also installs ruby-build as well as all the dependencies they
# require. But debian's version of ruby-build, even in the latest bookworm, is old (2022).
# Luckily rbenv basically uses ruby-build as a plugin. We remove apt's ruby-build then
# install ruby-build from its main branch. That way all ruby versions are available.
RUN apt remove -qy ruby-build && \
  git clone --branch v20231114 https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build && \
  "$(rbenv root)"/plugins/ruby-build/install.sh && \
  echo 'eval "$(rbenv init -)"' >> /root/.profile && \
  chmod 700 /root/.profile && \
  rm -rf /var/lib/apt/lists/*

# Ensure the rbenv init script in /root/.profile, added above, gets processed
# before each RUN from now on, even though the bash shells are non-interactive.
SHELL ["/bin/bash", "--login", "-c"]

RUN rbenv install $ruby_version && \
  rbenv global $ruby_version
RUN gem install -v 2.4.22 bundler && \
  bundle config --local build.mysql2 -- $(ruby -r rbconfig -e 'puts RbConfig::CONFIG["configure_args"]' | xargs -n1 | grep with-openssl-dir)

ADD . ${WORKDIR}
RUN bundle install
