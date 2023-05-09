from aws_lambda_powertools.utilities.typing import LambdaContext
import deploymentApi
import adminDeploymentApi
import clientDeploymentApi
from commons import app


@app.get("/deploy")
def deploy():
    return deploymentApi.deploy()


@app.post("/admin/deployment")
def create_deployment():
    return adminDeploymentApi.create_deployment_blueprint()


@app.put("/admin/deployment")
def update_deployment():
    return adminDeploymentApi.update_deployment_blueprint()


@app.post("/client-deployment")
def create_client_deployment():
    return clientDeploymentApi.create_client_deployment()


@app.put("/client-deployment")
def update_client_deployment():
    return clientDeploymentApi.update_client_deployment()


def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)
