# Especificamos la versión de Ruby
ARG RUBY_VERSION=3.3.5
FROM ruby:$RUBY_VERSION-slim AS base

# Definimos el directorio de la aplicación
ENV INSTALL_PATH /usr/src/app/
WORKDIR $INSTALL_PATH

# Instalamos las dependencias necesarias para la aplicación y PostgreSQL
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libjemalloc2 \
    libvips \
    postgresql-client \
    build-essential \
    libpq-dev \
    curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copiamos los archivos Gemfile para instalar las gems
COPY Gemfile* $INSTALL_PATH/
RUN bundle install

# Copiamos el código de la aplicación al contenedor
COPY . $INSTALL_PATH

# Creamos un usuario no-root para mayor seguridad
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails $INSTALL_PATH

# Cambiamos al usuario 'rails'
USER rails

# Exponemos el puerto 3000
EXPOSE 3000

# Definimos el script de entrada (entrypoint) que se encargará de preparar la base de datos
ENTRYPOINT ["bin/docker-entrypoint"]

# Comando por defecto para iniciar el servidor
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
