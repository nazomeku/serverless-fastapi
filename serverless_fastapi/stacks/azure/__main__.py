from pulumi import Config, export, FileArchive, Output, ResourceOptions
from pulumi_azure_native import resources, storage, web
from pulumi_command import local
from pulumi_random import RandomString
from pulumiverse_time import Sleep


function_app_code_path = '../../functions/api'

config = Config()
location = config.get('location')

resource_group = resources.ResourceGroup('ServerlessFastAPI')

storage_account = storage.StorageAccount(
    'StorageAccount',
    account_name=RandomString(
        'StorageAccountNameSuffix',
        length=8,
        number=False,
        special=False,
        upper=False,
    ),
    kind=storage.Kind.STORAGE_V2,
    resource_group_name=resource_group.name,
    sku=storage.SkuArgs(name=storage.SkuName.STANDARD_LRS),
)

primary_storage_key = Output.all(resource_group.name, storage_account.name).apply(
    lambda args: storage.list_storage_account_keys(
        account_name=args[1],
        resource_group_name=args[0],
    )
    .keys[0]
    .value,
)

storage_account_connection_string = Output.concat(
    'DefaultEndpointsProtocol=https;AccountName=',
    storage_account.name,
    ';AccountKey=',
    primary_storage_key,
    ';EndpointSuffix=core.windows.net',
)

app_service_plan = web.AppServicePlan(
    'AppServicePlan',
    kind='Linux',
    reserved=True,
    resource_group_name=resource_group.name,
    sku=web.SkuDescriptionArgs(name='Y1', tier='Dynamic'),
)

function_app = web.WebApp(
    'FunctionWebApp',
    kind='FunctionApp',
    resource_group_name=resource_group.name,
    server_farm_id=app_service_plan.id,
    site_config=web.SiteConfigArgs(
        app_settings=[
            web.NameValuePairArgs(
                name='AzureWebJobsFeatureFlags',
                value='EnableWorkerIndexing',
            ),
            web.NameValuePairArgs(
                name='AzureWebJobsStorage',
                value=storage_account_connection_string,
            ),
            web.NameValuePairArgs(
                name='ENABLE_ORYX_BUILD',
                value='true',
            ),
            web.NameValuePairArgs(
                name='FUNCTIONS_EXTENSION_VERSION',
                value='~4',
            ),
            web.NameValuePairArgs(
                name='FUNCTIONS_WORKER_RUNTIME',
                value='python',
            ),
            web.NameValuePairArgs(
                name='PYTHON_ENABLE_GUNICORN_MULTIWORKERS',
                value='true',
            ),
            web.NameValuePairArgs(
                name='SCM_DO_BUILD_DURING_DEPLOYMENT',
                value='true',
            ),
        ],
        linux_fx_version='Python|3.11',
    ),
)

# don't like that but couldn't find a better way
# there is some weird behavior with the `local.Command` and `depends_on` set to `function_app`
# that results in function name not being found while deploying with func azure command
function_creation_delay = Sleep(
    'FunctionCreationDelay',
    create_duration='15s',
    opts=ResourceOptions(depends_on=[function_app]),
)

function_asset = FileArchive(function_app_code_path)

azure_func_deploy = local.Command(
    'DeployCommand',
    create=function_app.name.apply(
        lambda name: f'cd {function_app_code_path} && func azure functionapp publish {name}',
    ),
    opts=ResourceOptions(depends_on=[function_creation_delay]),
    triggers=[function_asset],
)

export(
    'AppEndpoint',
    function_app.default_host_name.apply(lambda default_host_name: f'https://{default_host_name}'),
)
