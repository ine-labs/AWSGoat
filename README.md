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

![2](https://user-images.githubusercontent.com/65826354/184551000-29f59b56-cbcc-4daf-9dad-a40e35bd6e02.png)

**Step 3.** From the repository actions tab, select the module to deploy and run the ``Terraform Apply`` Workflow.

![3](https://user-images.githubusercontent.com/65826354/194799524-a814fba3-2936-47a3-bb11-9d65f65bbf60.png)

**Step 4.** Find the application URL in the Terraform output section.

![4](https://user-images.githubusercontent.com/65826354/184553744-c1ba94a1-0d67-4a86-b97d-ee7afe6c65fe.png)


### Manual Installation

The Steps for manually installing AWSGoat are inside their respective directories. 

For Module-1 : ``modules/module-1/README.md``

For Module-2 : ``modules/module-2/README.md``


# Modules

## Module 1

The first module features a serverless blog application utilizing AWS Lambda, S3, API Gateway, and DynamoDB. It consists of various web application vulnerabilities and facilitates exploitation of misconfigured AWS resources.

Overview of escalation paths for module-1

![10](https://user-images.githubusercontent.com/65826354/179526761-7f473e3d-f71c-429d-bf49-16958c5cb7a6.png)



## Module 2

The second module features an internal HR Payroll application, utilizing the AWS ECS infrastructure. It consists of various web application vulnerabilities and facilitates exploitation of misconfigured AWS resources.

Overview of escalation paths for module-2

![11](https://user-images.githubusercontent.com/65826354/194799899-2968e04a-c324-4c3a-bdf2-b33f86fc0e05.png)


**Recommended Browser:** Google Chrome

# Pricing

- **Module-1** the major incurred cost is for the EC2 instance i.e. **0.0125 USD / HR**. Other components like S3 and Lambda will not incur any significant charges.

- **Module-2** the major incurred cost is for the EC2 instance deployed by ECS, the RDS instance, and one SecretsManager secret (0.4 USD/Month) i.e. **0.0505 USD / HR**. Other components the Load Balancer will not incur any significant hourly charges.

# Contributors

Jeswin Mathai, Chief Architect, Lab Platform, INE  <jmathai@ine.com>

Nishant Sharma, Director, Lab Platform, INE <nsharma@ine.com>

Sanjeev Mahunta, Software Engineer (Cloud), INE <smahunta@ine.com>

Shantanu Kale, Cloud Developer, INE  <skale@ine.com>

Govind Krishna Lal Balaji, Cloud Developer Intern, INE <lkris@ine.com> 

Litesh Ghute, Software Engineer (Cloud) Intern, INE <lghute@ine.com> 

# Solutions

The manuals are available in the [solutions](solutions/) directory 

Module 1 Exploitation Videos: 

![gif](https://user-images.githubusercontent.com/65826354/194804917-b6f993f2-4bf7-4c6b-b946-b14dd645dc10.gif)

https://youtube.com/playlist?list=PLcIpBb4raSZEMosUmY8KpxPWtjKRMSmNx

# Documentation

For more details refer to the "AWSGoat.pdf" PDF file. This file contains the slide deck used for presentations.

# Screenshots

Module-1, Blog Application HomePage

![5](https://user-images.githubusercontent.com/65826354/179526784-2a1d7023-5c6f-4cfb-97b7-74b572b12829.png)


Module-2, HR Application User HomePage

![6](https://user-images.githubusercontent.com/65826354/194800860-e7eaa174-0948-4d35-b185-0325ed7ddcf7.png)


## Contribution Guidelines

* Contributions in the form of code improvements, module updates, feature improvements, and any general suggestions are welcome. 
* Improvements to the functionalities of the current modules are also welcome. 
* The source code for each module can be found in ``modules/module-<Number>/src`` this can be used to modify the existing application code.

# License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License v2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

# Sister Projects

- [AzureGoat](https://github.com/ine-labs/AzureGoat)
- GCPSheep (Coming Soon)
- [PA Toolkit (Pentester Academy Wireshark Toolkit)](https://github.com/pentesteracademy/patoolkit)
- [ReconPal: Leveraging NLP for Infosec](https://github.com/pentesteracademy/reconpal) 
- [VoIPShark: Open Source VoIP Analysis Platform](https://github.com/pentesteracademy/voipshark)
- [BLEMystique](https://github.com/pentesteracademy/blemystique)
