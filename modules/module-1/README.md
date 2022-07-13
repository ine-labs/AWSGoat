# Blog Application Setup and installations

## Steps to build application code

1. Make changes to the source code in ``src/``.

2. Create build folder

```
npm run build
```

3. Replace the build folder in ``resources/s3/webfiles/``

4. Copy the index.html file from  ``resources/s3/webfiles/build`` to ``resources/lambda/react`` and run the following commands on it.
```sh
sed -i 's,href="/,href="S3_BUCKET/,g' index.html
sed -i 's,src="/,src="S3_BUCKET/,g' index.html
```

5. Run the terraform apply action.
