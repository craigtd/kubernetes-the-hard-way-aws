# kubernetes-the-hard-way-aws

Working through [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) on [AWS](https://aws.amazon.com/)

The intent was to learn [AWS](https://aws.amazon.com/) and [Terraform](https://www.terraform.io/) and follows the work already done by [Slawek Zachcial](https://github.com/slawekzachcial/kubernetes-the-hard-way-aws)

To build the required infrastructure, use the following command:

```
cd terraform
terraform init
terraform apply
```

To tear down the infrastructure, use:
```
terraform destroy
```

Note: This version relies on [tls-private-key](https://www.terraform.io/docs/providers/tls/r/private_key.html) to generate a private key which is stored unencrypted in the terraform state file and is so not considered secure

