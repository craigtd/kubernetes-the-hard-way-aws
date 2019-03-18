# kubernetes-the-hard-way-aws

Working through [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) on [AWS](https://aws.amazon.com/)

The intent was to learn [AWS](https://aws.amazon.com/) and [Terraform](https://www.terraform.io/) and follows the work already done by [Slawek Zachcial](https://github.com/slawekzachcial/kubernetes-the-hard-way-aws)

#### Build Infrastructure

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

#### SSH Access

This version relies on [tls-private-key](https://www.terraform.io/docs/providers/tls/r/private_key.html) to generate a private key which is stored unencrypted in the terraform state file and is so not considered secure

Test SSH access by copying the content of `$.modules.resources.tls_private_key.k8s.primary.attributes.private_key_pem` from the terraform.tfstate to a local `private-key.pem`.

Obtain the public IP for one of the compute instances via the AWS Console then use the below commands:

```
ssh-add <path-to-private-key.pem>
ssh -A ubuntu@<public_ip_address>
```

#### Client & Server Certificates

Generate the Kubelet Client Certificates

WIP