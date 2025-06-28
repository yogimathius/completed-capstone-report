FROM rust:slim as builder

# Install mdbook
RUN cargo install mdbook

# Copy source files
COPY . /src
WORKDIR /src

# Build the book
RUN mdbook build

# Use nginx to serve the static files
FROM nginx:alpine

# Copy built book files
COPY --from=builder /src/book /usr/share/nginx/html

# Copy custom nginx config for SPA-like routing
RUN echo 'server { \
    listen 8080; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript; \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"] 