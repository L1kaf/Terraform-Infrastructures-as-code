### Hexlet tests and linter status:
[![Actions Status](https://github.com/L1kaf/devops-for-programmers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/L1kaf/devops-for-programmers-project-77/actions)

### Description:
---
This repository explores Terraform's ability to implement the Infrastructure as code (IaC) concept

Yandex Cloud infrastructure is used in the project

Demo: http://buryka-test.ru/

### System Requirements:
---
* Linux
* Ansible
* Terraform
* Request 2.31.0

### Preparation:
---
Create a configuration file
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
#### It is necessary to add the secrets.backend.tfvars file and specify values for the variables:

`bucket` - bucket name in the Yandex Cloud infrastructure. <br>
`access_key` - identifier of the static access key to the service account in Yandex Cloud. <br>
`secret_key` - token of the static secret key of access to the service account in Yandex Cloud. <br>
`dynamodb_table` - table name for fixing state locks. <br>
`dynamodb_endpoint` - URL to the api for working with the table. <br>

#### It is necessary to add the secrets.auto.tfvars file and specify values for the variables

`yc_token` - a token to access the cloud infrastructure. <br>
`yc_folder` - identifier of the directory in the cloud. <br>
`yc_user` - the username used in the operations. <br>
`db_name` - database name. <br>
`db_user` - database user name. <br>
`db_password` - database user password. <br>

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

Application and system pre-configuration:
```bash
make install
```

Deploy applications to remote machines:
```bash
make deploy
```
