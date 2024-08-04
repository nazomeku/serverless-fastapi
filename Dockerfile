FROM python:3.11-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Install Azure CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

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
