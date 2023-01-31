# Objectives

We will use ZAP to identify if a sensitive resource was left unprotected by developers. 

# Solutions

Go to the home page of the lambda request URL provided. On that page, right-click and select the 'inspect' option. This will lead you to the network view, which allows us to see and analyze the network requests that make up each page load within a single user's session. We can use this view to investigate the page for flaws in access control.

Reload the page after going to the network view to view all the network requests. Amongst those requests, you have to click on the network request named 'list-posts' and we will get the request URL for it, as shown in the image below:

![](https://user-images.githubusercontent.com/65826354/179528203-e6dc2171-216e-48aa-8efc-03d2c54260e0.png)

So we have acquired the request URL that we need to explore. Now we are going to use OWASP ZAP to further explore the URL.

OWASP ZAP is an open-source tool and is used to perform penetration tests. The main goal of ZAP is to allow easy penetration testing to find the vulnerabilities in web applications. We will use ZAP here for the same purpose, to find the vulnerabilities in our application.

So now open up ZAP and on the home page, select the 'Manual Explore' option. Inside that, you will find a field named 'URL to explore'. In that field, insert the request URL for network request 'list-posts' that you just acquired in the above step. After entering the URL, click on the 'Launch Browser' button. We will get the following output at the site's tree structure.

![](https://user-images.githubusercontent.com/65826354/179528227-7ea08a4b-9b7b-4746-a761-ebb2dd105e02.png)

Now go to:

```
v1 -> GET:list-posts -> Attack -> Fuzz...
```

We will be fuzzing the API endpoint in this task. Fuzzing is a type of testing that can be performed through ZAP, where the user sends unexpected or random data as the inputs of a website. The fuzzer doesn't report any issues, it just throws the text we specify at the field and tells us how the application responded to it. We need to manually examine the results and decide if they are real vulnerabilities.

The fuzzer window will now be open on your screen. Then select the text list-posts as shown in the image below as this is the field we want to replace with dictionary values.

![](https://user-images.githubusercontent.com/65826354/179528233-939d1d6e-9681-457c-81e0-78e4567a8546.png)

Now, as you have selected the text, click on add as shown in the above image and we will observe that the payload pops up. Again click on add, and an add payload window will pop up.

The default type of the value to be added is String. But in this task, we need to add a file, so go to the type dropdown menu and select type as 'File'. In the next step, we need to give the address of the file that we need to add. Here we are using dirb's common.txt wordlist.

```
/usr/share/wordlists/dirb/common.txt
```

After finding the correct file, click on 'add' to the file as the input at the selected text. Now in the fuzzer window, go to the Options tab to change the parameter 'Concurrent Scanning threads per scan'. Its initial value would be 15, change it to 20. It signifies the number of threads the scanner will use per scan. Increasing the number of threads will speed up the scan but may put extra strain on the PC.

After successfully changing the parameter, click on 'start fuzzer' to start the scanning. Once the scanning starts, we will see that all of our payloads are being sent, but most of them are returning a '403 Forbidden' code, which is completely expected. We will continue our scan until we find a vulnerability.

After some time, we will see that the payload dump is returning code 200, status OK. We have finally fuzzed an API endpoint. We can click on 'Code' if we can't find it. It will look like this:

![](https://user-images.githubusercontent.com/65826354/179528237-2e6394f6-16f9-4696-bfe2-c1d220e03d17.png)

Now that we have found our access flaw, right-click on the dump payload shown in the above image and then copy its URL.

Now open the browser and paste the URL of the dump payload that we just grabbed. We will see that we are getting the output where we have access to all the data of all the users, sensitive data like emails, passwords, addresses, and secret questions/answers as well. The output will be something like this:

![](https://user-images.githubusercontent.com/65826354/179528247-75424528-75c2-40b3-b69b-9f36b6c32b28.png)

So we can see that we have found a sensitive data exposure flaw, and exploited it using ZAP's fuzzer to gain access to unauthorized data.
