# HR Application Setup and installations

## Steps to build application code


1. Make changes to the source code in ``src/``.

2. Create a Public Repository in AWS ECR, and follow the push commands to build and push the updated image.

3. Retrieve the image URI from the ECR repository on AWS console.

4. Replace the image value, in ``../resources/ecs/task_definition.json`` with the image uri.

5. Run the terraform apply action.