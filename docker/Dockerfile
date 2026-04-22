# ===========================
# Base Image: PHP 8.2 FPM
# ===========================
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# ===========================
# Install System Dependencies
# ===========================
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===========================
# Install Node.js & NPM
# ===========================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===========================
# Install PHP Extensions
# ===========================
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    xml

# ===========================
# Install Redis Extension
# ===========================
RUN pecl install redis && docker-php-ext-enable redis

# ===========================
# Install Composer
# ===========================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ===========================
# Create Laravel User
# ===========================
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# Set permissions
RUN chown -R www:www /var/www/html

USER www

EXPOSE 9000

CMD ["php-fpm"]
