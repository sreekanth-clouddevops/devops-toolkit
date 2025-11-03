# ---------- builder: run lint & tests inside container ----------
FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash make git curl jq ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . /app
# Fail fast if quality gates fail
RUN make lint && make test

# ---------- runtime: minimal tools to run scripts ----------
FROM debian:bookworm-slim AS runtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash jq ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# Copy only what we need at runtime
COPY --from=builder /app/bin /app/bin
COPY --from=builder /app/scripts /app/scripts
COPY --from=builder /app/data /app/data
# Optional: keep README and Makefile for reference
COPY --from=builder /app/README.md /app/README.md

ENV PATH="/app/bin:${PATH}"

# Simple healthcheck: ensure system_check runs
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD /bin/bash -c "/app/bin/system_check.sh >/dev/null 2>&1 || exit 1"

CMD ["/bin/bash","-c","echo 'DevOps toolkit ready'; ls -la /app && /bin/bash"]
