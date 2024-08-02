## Serverless FastAPI with Azure Functions

This project demonstrates the integration of FastAPI with Azure Functions, showcasing a serverless implementation.
The application can be deployed on Azure using [Pulumi](https://www.pulumi.com/), an infrastructure as code solution.

### How to start

Create the Python environment and install the project dependencies:

```
$ pip install --upgrade pip
$ pip install -r requirements-dev.txt
```

You can run the code quality checks with a single command:

```
pre-commit run -a
```

### Deploying to Azure with Pulumi

To deploy your Azure Function to Azure using Pulumi, follow these steps:

1. [Install Pulumi](https://www.pulumi.com/docs/install/) and [Azure Function Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).
2. Adjust project target location if necessary in `Pulumi.yaml` file.
3. Deploy Azure resources with command: `pulumi up -C serverless_fastapi/stacks/azure/`

### Cleaning up

1. Remove Azure resources with command: `pulumi destroy -C serverless_fastapi/stacks/azure/`
2. Remove Pulumi stack with command: `pulumi stack rm -C serverless_fastapi/stacks/azure/`

### Check API locally using Core Tools (optional)

Install Azure Functions Core Tools. For more detailed instructions, you can refer to the [official documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).

Navigate to the project directory:

```
$ cd serverless_fastapi/functions/api
```

Start the Azure Function locally using the following command:

```
$ func start
```
