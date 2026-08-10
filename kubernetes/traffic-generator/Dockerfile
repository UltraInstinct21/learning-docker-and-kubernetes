# ==============================================================================
# THEORY: TRAFFIC GENERATOR CONTAINER IMAGE
# ==============================================================================
# A lightweight Alpine Linux container with `curl` installed to simulate client
# traffic against Kubernetes services for testing load balancing and DNS.
#
# DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build Docker Image:
#    docker build -t ultrainstinct21/traffic-gen:1.0.0 .
#
# 2. Test locally with Docker:
#    docker run --rm ultrainstinct21/traffic-gen:1.0.0 https://httpbin.org/get 2
#
# 3. Push to Registry:
#    docker push ultrainstinct21/traffic-gen:1.0.0
# ==============================================================================

FROM alpine:3.20

WORKDIR /app

# Install curl for HTTP requests
RUN apk add --no-cache curl

# Copy the shell script and ensure executable permissions
COPY traffic-gen.sh traffic-gen.sh 
RUN chmod +x traffic-gen.sh

# ENTRYPOINT allows passing target URL and interval as arguments
ENTRYPOINT [ "./traffic-gen.sh" ]