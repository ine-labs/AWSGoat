# Objectives

We will try to perform an SSRF attack and try to fetch the */etc/passwd/* file from the Lambda Execution Environment.

# Solution

## Step 1: Interact with the Web Application.

Open the web application put in the login credentials and interact with the web app.

![](https://user-images.githubusercontent.com/65826354/179528325-a6dd1cbf-9f63-4c17-86ea-55a26cb8ffc0.png)

![](https://user-images.githubusercontent.com/65826354/179528330-7bf9f93e-affd-4525-88ae-57b763ecf076.png)

## Step 2: From the side navigation menu select Newpost

![](https://user-images.githubusercontent.com/65826354/179528339-b0f62e1b-55e8-48a2-b3d7-90ef9ef841dc.png)

Enter any demo headline for the post like, "Sample post check for SSRF". Also, fill in the Author's Name.

In the "Enter URL of image" field, write down the below-mentioned payload.

Payload:

```
file:///etc/passwd/
```

The file scheme is used to access files stored on the local system, the payload if successful will let us view the contents of file  */etc/passwd*. 

![](https://user-images.githubusercontent.com/65826354/179528349-06a08046-9e17-47b3-b83f-ef707563b5e8.png)

## Step 3: Go to inspect elements and click on the upload button.

First, right-click on the screen and you will find inspect elements, click on that and open the "Network" tab. After that, click on the "Upload" button. 

![](https://user-images.githubusercontent.com/65826354/179528360-ed2dec2a-f665-488b-88ba-fbd85c1a6e56.png)

At the bottom, you will get a notification that "URL File uploaded successfully". After that, open the response and copy the URL.

![](https://user-images.githubusercontent.com/65826354/179528370-b3067dc7-0f35-463a-8a35-c76f93020f25.png)

## Step 4: Download the data and try to open it.

To download the data of */etc/passwd/* file visit the copied URL (from Step 3).

After the successful download of data, you will find that the data is in .png format. When you will try to open it you will get an error.

![](https://user-images.githubusercontent.com/65826354/179528384-afefc9e8-f0f3-4445-bc15-511ce1bc8f92.png)

## Step 5: Open the terminal to display the data.

Open the terminal and run the below-mentioned command to display the content of the */etc/passwd/* file.

Command:

```bash
cat <File_Name>
```

eg. 

```bash
cat 20220711202454833709.png
```
![](https://user-images.githubusercontent.com/65826354/179528409-774753f7-7820-496c-9d95-7c99d491d39b.png)