# Lightweight nginx image for static website
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy all static website files
COPY . /usr/share/nginx/html/

# Remove Dockerfile and nginx.conf from served files
RUN rm -f /usr/share/nginx/html/Dockerfile /usr/share/nginx/html/nginx.conf

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
