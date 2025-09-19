# Stage 1: Build React app
FROM nginx:alpine

# Copy build output to nginx html directory
COPY dist /usr/share/nginx/html

# Expose port 80 (your requirement)
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
