# Use an outdated and unmaintained base image with known vulnerabilities
FROM ubuntu:14.04

# Run the container as root (privilege escalation risk)
USER root

# Set the working directory
WORKDIR /app

# Install outdated packages with known vulnerabilities
RUN apt-get update && apt-get install -y \
    apache2=2.4.7-1ubuntu4.18 \
    php5=5.5.9+dfsg-1ubuntu4.29 \
    curl=7.35.0-1ubuntu2.20

# Install a vulnerable version of OpenSSL with known vulnerabilities
RUN apt-get install -y openssl=1.0.1f-1ubuntu2.27

# Use a non-verified, non-encrypted HTTP source for downloading a file
RUN curl http://insecure.example.com/script.sh -o /usr/local/bin/script.sh \
    && chmod +x /usr/local/bin/script.sh

# Expose ports (potential for unnecessary exposure)
EXPOSE 80 443

# Use a weak password for a service (hardcoded credentials)
ENV ADMIN_PASSWORD=1234

# Run a service without security best practices (no configuration hardening)
CMD ["apache2ctl", "-D", "FOREGROUND"]
