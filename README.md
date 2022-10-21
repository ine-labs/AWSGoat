# AWSGoat : A Damn Vulnerable AWS Infrastructure

![1](https://user-images.githubusercontent.com/65826354/179526664-cb123612-7f9a-41fe-bab2-eb6b3b2518d7.png)

Compromising an organization's cloud infrastructure is like sitting on a gold mine for attackers. And sometimes, a simple misconfiguration or a vulnerability in web applications, is all an attacker needs to compromise the entire infrastructure. Since the cloud is relatively new, many developers are not fully aware of the threatscape and they end up deploying a vulnerable cloud infrastructure.

AWSGoat is a vulnerable by design infrastructure on AWS featuring the latest released OWASP Top 10 web application security risks (2021) and other misconfiguration based on services such as IAM, S3, API Gateway, Lambda, EC2, and ECS. AWSGoat mimics real-world infrastructure but with added vulnerabilities. It features multiple escalation paths and is focused on a black-box approach.

The project will be divided into modules and each module will be a separate web application, powered by varied tech stacks and development practices. It will leverage IaC through terraform and GitHub actions to ease the deployment process.

**Presented at**

- [OWASP Singapore Chapter](https://owasp.org/www-chapter-singapore/)
- [BlackHat USA 2022](https://www.blackhat.com/us-22/arsenal/schedule/index.html#awsgoat--a-damn-vulnerable-aws-infrastructure-27999)
- [DC 30: Demo Labs](https://forum.defcon.org/node/242059)
- [Rootcon 16](https://rootcon.org/)

### Developed with :heart: by [INE](https://ine.com/) 

[<img src="https://user-images.githubusercontent.com/25884689/184508144-f0196d79-5843-4ea6-ad39-0c14cd0da54c.png" alt="drawing" width="200"/>](https://discord.gg/TG7bpETgbg)

## Built With

* AWS
* React
* Python 3
* Terraform
* PHP 
* Docker 

## Vulnerabilities

The project is scheduled to encompass all significant vulnerabilities including the OWASP TOP 10 2021, and popular cloud misconfigurations.
Currently, the project  contains the following vulnerabilities/misconfigurations.

* XSS
* SQL Injection
* Insecure Direct Object reference
* Server Side Request Forgery on Lambda Environment
* Sensitive Data Exposure and Password Reset
* S3 Misconfigurations
* IAM Privilege Escalations
* ECS Container Breakout


# Getting Started

### Prerequisites
* An AWS Account
* AWS Access Key with Administrative Privileges


### Installation

To ease the deployment process the user just needs to fork this repo, add their AWS Account Credentials to GitHub secrets, and run the Terraform Apply Action. This workflow will deploy the whole infrastructure and output the hosted application's URL. 

Here are the steps to follow:

**Step 1.** Fork the repo

**Step 2.** Set the GitHub Action Secrets:

```
AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY
```

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/184551000-29f59b56-cbcc-4daf-9dad-a40e35bd6e02.png">
</p>

**Step 3.** From the repository actions tab, select the module to deploy and run the ``Terraform Apply`` Workflow.

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/194799524-a814fba3-2936-47a3-bb11-9d65f65bbf60.png">
</p>

**Step 4.** Find the application URL in the Terraform output section.

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/184553744-c1ba94a1-0d67-4a86-b97d-ee7afe6c65fe.png">
</p>


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

**Step 3.** Traverse into the respective modules' directory and use terraform to deploy AWSGoat
```sh
cd modules/module-<Number>
terraform init
terraform apply --auto-approve
```

# Modules

## Module 1

The first module features a serverless blog application utilizing AWS Lambda, S3, API Gateway, and DynamoDB. It consists of various web application vulnerabilities and facilitates exploitation of misconfigured AWS resources.

Escalation Path:

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/179526761-7f473e3d-f71c-429d-bf49-16958c5cb7a6.png">
</p>


## Module 2

The second module features an internal HR Payroll application, utilizing the AWS ECS infrastructure. It consists of various web application vulnerabilities and facilitates exploitation of misconfigured AWS resources.

Escalation Path:

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/194799899-2968e04a-c324-4c3a-bdf2-b33f86fc0e05.png">
</p>


**Recommended Browser:** Google Chrome

# Pricing

The resources created with the deployment of AWSGoat will not incur any charges if the AWS account is under the free tier/trial period. However, upon exhaustion/ineligibility of the free tier/trial, the following charges will apply for the US-East region: 

Module 1: **$0.0125/hour**

Module 2: **$0.0505/hour**

# Contributors

Jeswin Mathai, Chief Architect, Lab Platform, INE  <jmathai@ine.com>

Nishant Sharma, Director, Lab Platform, INE <nsharma@ine.com>

Sanjeev Mahunta, Software Engineer (Cloud), INE <smahunta@ine.com>

Shantanu Kale, Cloud Developer, INE  <skale@ine.com>

Govind Krishna Lal Balaji, Cloud Developer Intern, INE <lkris@ine.com> 

Litesh Ghute, Software Engineer (Cloud) Intern, INE <lghute@ine.com> 

# Solutions

The manuals are available in the [solutions](solutions/) directory 

Module 1 Exploitation Videos: <https://www.youtube.com/playlist?list=PLcIpBb4raSZEMosUmY8KpxPWtjKRMSmNx>


[![11](https://user-images.githubusercontent.com/65826354/194854747-26a95cb7-7f8a-4d52-8a36-1ede79a62126.gif)](https://www.youtube.com/playlist?list=PLcIpBb4raSZEMosUmY8KpxPWtjKRMSmNx)



# Documentation

For more details refer to the "AWSGoat.pdf" PDF file. This file contains the slide deck used for presentations.

# Screenshots

Module 1:

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/179526784-2a1d7023-5c6f-4cfb-97b7-74b572b12829.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/179526796-fa4fa422-ffb5-4ff4-a2eb-1468e9c81fd6.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/179526801-6eb85d63-b7df-4fac-98f6-8afb834d2f49.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/179526804-78f87773-965d-4eee-a5bf-fb1c1d448234.png">
</p>


Module 2:

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/194800860-e7eaa174-0948-4d35-b185-0325ed7ddcf7.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/65826354/194801060-8ab1ba55-b97c-4cea-817d-0c517a1924b3.png">
</p>


## Contribution Guidelines

* Contributions in the form of code improvements, module updates, feature improvements, and any general suggestions are welcome. 
* Improvements to the functionalities of the current modules are also welcome. 
* The source code for each module can be found in ``modules/module-<Number>/src`` this can be used to modify the existing application code.

# License

This program is free software: you can redistribute it and/or modify it under the terms of the MIT License.

You should have received a copy of the MIT License along with this program. If not, see https://opensource.org/licenses/MIT.

# Sister Projects

- [AzureGoat](https://github.com/ine-labs/AzureGoat)
- GCPGoat (Coming Soon)
- [PA Toolkit (Pentester Academy Wireshark Toolkit)](https://github.com/pentesteracademy/patoolkit)
- [ReconPal: Leveraging NLP for Infosec](https://github.com/pentesteracademy/reconpal) 
- [VoIPShark: Open Source VoIP Analysis Platform](https://github.com/pentesteracademy/voipshark)
- [BLEMystique](https://github.com/pentesteracademy/blemystique)
