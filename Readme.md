## Prover Server

Prover Server is a REST API Wrapper for [go-rapidsnark](https://github.com/iden3/go-rapidsnark), with AWS CloudFormation based deployment config to deploy an ARM64 build of the prover to AWS Lambda with AWS ECR, exposed behind a Lambda function URL without authorization. To make minimal changes to the server itself, so it can remain a standard HTTPs server, [aws-lambda-web-adapter](https://github.com/awslabs/aws-lambda-web-adapter) is leveraged.

List of implemented features:
* Generate proof
* Verify proof

## Deployment
### Setup

1. Edit config file `configs/prover.yaml`
2. Put compiled circuits into `<circuitsBasePath>/<circuitName>` directory. Where `<circuitsBasePath>` is config option with default value `circuits`, and `<circuitName>` is name of the circuit that will be passed as a param to an API call.
   See [SnarkJS Readme](https://github.com/iden3/snarkjs) for instructions on how to compile circuits.

### AWS Lambda with ECR Image Deployment

Assuming you're on linux or macos, the Docker image can be built and deployed to AWS ECR as follows with AWS CloudFormation. It assumes you have the AWS CLI installed. To create an ECR repository to store the built image, please see [creating an Amazon ECR private repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html). Please substitute the values in square brackets with your respective values.

```sh
aws ecr get-login-password --region [AWS Region] | docker login --username AWS --password-stdin [AWS Account ID].dkr.ecr.[AWS Region].amazonaws.com
docker

docker build --platform linux/arm64 -t prover-server .

docker tag prover-server:latest [AWS Account ID].dkr.ecr.[AWS Region].amazonaws.com/prover-server:latest

docker push [AWS Account ID].dkr.ecr.[AWS Region].amazonaws.com/prover-server:latest
```

Once deployed to ECR, create the AWS lambda stack with CloudFormation (see [template.yaml](./template.yaml)).

```sh
sam validate
sam build
sam deploy --guided
```

To remove a deployment, the following command can be used:
```sh
aws cloudformation delete-stack --stack-name [your-stack-name] --region [AWS Region]
```

Did you receive a pass init error? See https://docs.docker.com/desktop/get-started/#credentials-management-for-linux-users.

## API
### Generate proof

```
POST /api/v1/proof/generate
Content-Type: application/json
{
  "inputs": {...}, // circuit specific inputs
  "circuit_name": "..." // name of a directory containing circuit_final.zkey, verification_key.json and circuit.wasm files
}
```


## License

Please check the LICENSE file for more details.
