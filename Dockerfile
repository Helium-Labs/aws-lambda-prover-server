# Main image
FROM public.ecr.aws/lambda/provided:al2023-arm64
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.4 /lambda-adapter /opt/extensions/lambda-adapter
ENV PORT=8080

# Install necessary tools and dependencies for ARM build
RUN dnf install -y golang gcc gcc-c++ \
    && go env -w GOARCH=arm64 GOOS=linux \
    && go env -w GOPROXY=direct

# Set up Go paths
ENV GOPATH=/go
ENV PATH="$GOPATH/bin:$PATH"

# Set working directory
WORKDIR /home/app

# Copy source files
COPY . .

# Prepare Go environment
RUN go mod tidy
RUN go mod download

# Build main binaries for ARM architecture
RUN GOARCH=arm64 GOOS=linux go build -o ./prover ./cmd/prover/prover.go
RUN GOARCH=arm64 GOOS=linux go build -tags="rapidsnark_noasm" -o ./prover_noasm ./cmd/prover/prover.go

# Copy entrypoint and additional configurations
COPY docker-entrypoint.sh /usr/local/bin/

# Set the command to run the application
ENTRYPOINT ["docker-entrypoint.sh"]

# Expose application port
EXPOSE 8080