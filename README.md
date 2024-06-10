### Hexlet tests and linter status:
[![Actions Status](https://github.com/L1kaf/devops-for-programmers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/L1kaf/devops-for-programmers-project-77/actions)

### Description:
---
This repository explores Terraform's ability to implement the Infrastructure as code (IaC) concept

Yandex Cloud infrastructure is used in the project

### System Requirements:
---
* Linux
* Ansible
* Terraform
* Request 2.31.0

### Preparation:
---
Создать файл конфигурации
```bash
nano ~/.terraformrc
```
Add a block:

```bash
provider_installation {
    network_mirror {
        url = "https://terraform-mirror.yandexcloud.net/"
        include = ["registry.terraform.io/*/*"]
    }
    direct {
        exclude = ["registry.terraform.io/*/*"]
    }
}
```
It is necessary to add the secrets.backend.tfvars file and specify values for the variables:

bucket - bucket name in the Yandex Cloud infrastructure.
access_key - identifier of the static access key to the service account in Yandex Cloud.
secret_key - token of the static secret key of access to the service account in Yandex Cloud.
dynamodb_table - table name for fixing state locks.
dynamodb_endpoint - URL to the api for working with the table.

It is necessary to add the secrets.auto.tfvars file and specify values for the variables

yc_token - a token to access the cloud infrastructure.
yc_folder - identifier of the directory in the cloud.
yc_user - the username used in the operations.
db_name - database name.
db_user - database user name.
db_password - database user password.

### Usage:
---
Terraform initialization:
```bash
make init
```

Launching the execution of terraform infrastructure tasks:
```bash
make apply
```

Deletion of previously created infrastructure:
```bash
make destroy
```
