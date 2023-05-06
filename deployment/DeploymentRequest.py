
class DeploymentRequest:
    """Data Transfer Object between Services when Requesting a Deployment for a Specific Client

    Attributes
        client_id    -- Unique Client Identifier Requesting this deployment
        template_id  -- Deployment Template Identifier to be deployed
        tf_variables -- Terraform Variables to be given to the Deployment Hub
        tf_plan_path -- Terraform plan path inside the S3 buckets hosting the different plans
    """

    def __init__(self, client_id, template_id, tf_variables=None, tf_plan_path=""):
        if tf_variables is None:
            tf_variables = {}

        self.client_id = client_id
        self.template_id = template_id
        self.terraform_variables = tf_variables
        self.terraform_plan_path = tf_plan_path
