# HR Application Setup and installations

## Steps to build application code


1. Make changes to the source code in ``src/src``.

2. Create a Public Repository in AWS ECR, and follow the commands to build and push the updated image.

3. Retrieve the image URI from ECR repository on AWS console.

4. Replace the image uri, in ``ecs/task_definition.json``.

5. Run the terraform apply action.