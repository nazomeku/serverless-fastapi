FROM python:3.11-slim

COPY --from=ghcr.io/astral-sh/uv:0.4.3 /uv /bin/uv

WORKDIR /app

COPY . /app

# Install project dependencies
RUN uv pip compile pyproject.toml --output-file requirements.txt --quiet && \
    uv pip install --system --no-cache -r requirements.txt

# Install required system tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Azure Functions Core Tools
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
    echo "deb [arch=amd64] https://packages.microsoft.com/debian/$(lsb_release -rs | cut -d'.' -f 1)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends azure-functions-core-tools-4  && \
    rm -rf /var/lib/apt/lists/*

# Invariant mode for func command to run properly
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Install Pulumi
RUN curl -fsSL https://get.pulumi.com | sh

# Add Pulumi to PATH
ENV PATH="/root/.pulumi/bin:${PATH}"

ENTRYPOINT ["/bin/bash"]

CMD ["tools/deploy.sh"]
