# Objective

Perform an XSS injection attack on a given web application.

# Solutions

After you launch the web application, go to the search bar and try out some basic searches.

Now we will try out XSS attacks. Cross-Site Scripting (XSS) attacks are a type of injection, where malicious scripts are injected into websites. XSS attacks occur when an attacker uses a web application to send malicious code, generally in the form of a browser-side script, to a different end-user.

XSS flaws can be difficult to identify in a web application. We can perform a security review of the HTTP code and search for all places where input from an HTTP request could make its way into the HTML output.

The standard command for testing the application for XSS vulnerability is:

```
<script>alert('1')</script>
```

We can paste this command into any comment field (search bar in our case). An alert box popping up on our screen would have confirmed that our application is vulnerable to XSS injection attacks, but this doesn't work here.

XSS attacks may be conducted without using the script tags. Other tags and attributes can also help us test it. We can try using the image tag to check for reflected XSS. The below-mentioned payload is an image tag that tries to load an image with the source ``a`` as specified which does not exist and would throw an error. We then use the onerror field to execute our script payload, in this case, alert('xss')

```
<img src='a' onerror=alert('xss')>
```

An alert pops up proving that the application is vulnerable to XSS injection attacks.

![](https://user-images.githubusercontent.com/65826354/179527017-56acbc0d-4fc1-4d86-bee9-e96efaf6f48c.png)
