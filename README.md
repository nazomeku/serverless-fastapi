## Serverless FastAPI with Azure Functions

This project demonstrates the integration of FastAPI with Azure Functions, showcasing a serverless implementation.
The application can be deployed on Azure using [Pulumi](https://www.pulumi.com/), an infrastructure as code solution.

### Deploying to Azure with Pulumi

Deploy the application to Azure using Docker or locally on Linux.

#### Deployment with Docker (recommended)

1. Based on `.env.example`, create a `.env` file with the necessary environment variables.
1. Adjust the target location in Pulumi.yaml if necessary.
1. Build the Docker image:
   ```bash
   $ docker build -t serverless-fastapi .
   ```
1. Run the Docker container to deploy the application:
   ```bash
   $ docker run --env-file .env serverless-fastapi
   ```
1. To remove the resources completely from Azure along with Pulumi stack run:
   ```bash
   $ docker run --env-file .env serverless-fastapi tools/destroy.sh
   ```

#### Deployment on Linux

This will require some additional tools and configuration.

1. Install [Pulumi](https://www.pulumi.com/docs/install/), [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and [Azure Function Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).
1. Get Pulumi token and Azure credentials.
1. Adjust the target location in Pulumi.yaml if necessary.
1. Deploy Azure resources with command:
   ```bash
   pulumi up -C serverless_fastapi/stacks/azure/
   ```
1. Clean up Azure resources with command:
   ```bash
   pulumi destroy -C serverless_fastapi/stacks/azure/
   ```
1. Remove Pulumi stack with command:
   ```bash
   pulumi stack rm -C serverless_fastapi/stacks/azure/
   ```

### Local development

To check the application locally, you can install the dependencies with package manager eg. [uv](https://github.com/astral-sh/uv):

```bash
$ uv sync
$ source .venv/bin/activate
```

You can run the code quality checks with a single command:

```
$ pre-commit run -a
```

#### Check API locally using Core Tools

Install [Azure Function Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).

Navigate to the function directory:

```bash
$ cd serverless_fastapi/functions/api
```

Start the Azure Function locally:

```bash
$ func start
```
