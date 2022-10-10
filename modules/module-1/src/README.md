# Blog Application Setup and installations

## Steps to build application code

1. Create node_modules folder by executing the following command in ``src/``
   
   ```
   npm install
   ```

2. Make changes to the source code in ``src/src``.

3. Create build folder in ``src/`` by executing the following command.

```
npm run build
```

4. After creating build folder, follow inside the folder and remove the _redirects file.

5. Replace the build folder in ``resources/s3/webfiles/``

6. Copy the index.html file from  ``resources/s3/webfiles/build`` to ``resources/lambda/react`` and run the following commands on it. On MacOS, ```-i``` might not be required for the following command.

```sh
sed -i 's,href="/,href="S3_BUCKET/,g' index.html
sed -i 's,src="/,src="S3_BUCKET/,g' index.html
```

7. Replace S3_BUCKET in index.html file located in ``resources/lambda/react``

8. Run the terraform apply action.