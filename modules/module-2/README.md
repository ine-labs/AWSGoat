# AWSGoat : A Damn Vulnerable AWS Infrastructure

![1](https://user-images.githubusercontent.com/65826354/179526664-cb123612-7f9a-41fe-bab2-eb6b3b2518d7.png)

### Developed with :heart: by [INE](https://ine.com/) 

[<img src="https://user-images.githubusercontent.com/25884689/184508144-f0196d79-5843-4ea6-ad39-0c14cd0da54c.png" alt="drawing" width="200"/>](https://discord.gg/TG7bpETgbg)

## Built With

* AWS
* PHP
* Docker
* Terraform

## Vulnerabilities

The project is scheduled to encompass all significant vulnerabilities including the OWASP TOP 10 2021, and popular cloud misconfigurations.
Currently, the project  contains the following vulnerabilities/misconfigurations.

* SQL Injection
* Insecure Direct Object reference
* Sensitive Data Exposure and Password Reset
* Container Breakout
* IAM Privilege Escalations

# Getting Started

### Prerequisites
* An AWS Account
* AWS Access Key with Administrative Privileges

### Manual Installation

Manually installing AWSGoat would require you to follow these steps:

(Note: This requires a Linux Machine, with the /bin/bash shell available)

**Step 1.** Clone the repo
```sh
git clone https://github.com/ine-labs/AWSGoat
```

**Step 2.** Configure AWS User Account Credentials
```sh
aws configure
```

**Step 3.** Traverse into module-2 directory and use terraform to deploy AWSGoat
```sh
cd modules/module-2
terraform init
terraform apply --auto-approve
```
# Documentation

For more details refer to the "AWSGoat.pdf" PDF file. This file contains the slide deck used for presentations.

# Screenshots

HR Application User HomePage

![5](https://user-images.githubusercontent.com/65826354/194800860-e7eaa174-0948-4d35-b185-0325ed7ddcf7.png)

HR Application Payslips Page

![6](https://user-images.githubusercontent.com/65826354/194800937-7d9674d0-9766-4ce7-ad85-269088f1c3da.png)

HR Application Leave Page

![7](https://user-images.githubusercontent.com/65826354/194800981-bf75799b-29e1-43d6-992f-53054ac08552.png)

HR Application Apply Reimbursements Page

![8](https://user-images.githubusercontent.com/65826354/194801060-8ab1ba55-b97c-4cea-817d-0c517a1924b3.png)

HR Application Complaints Page

![9](https://user-images.githubusercontent.com/65826354/194801108-ba27d83a-49d4-4509-af84-359d0b613252.png)