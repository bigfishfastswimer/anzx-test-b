# anzx-test-b

An simple app operables web-style API or service provider.


## Local Development
---
### Prerequisite: 

- Run the commands on local laptop with `make` and `docker` installed

### Build
_Select your own image tag_ :
```sh
TAG_NAME=latest make build-runtime
```
### Test
```sh
make local-test
```
### Lint
```sh
make local-lint
```
### Security Scan
_lease ensure login to [snyk](https://app.snyk.io/org/) FIRST with_ `docker scan --login`
```sh
TAG_NAME=latest make local-scan
```
### Run
_Select your own image tag_ :
```sh
TAG_NAME=latest make local-run
```
## Remote CICD
---
### GitOps With GitHub Actions and EKS
In this project, release activities have been handled by `Weave GitOps` workflow in combination with `GitHub Actions` and `EKS` which is an AWS managed Kubernetes service


#### The workflow started from local developer laptop:
 - developer create feature or bug-fix branches off main/master
 - upon the completion of development work, perform local unit test, lint and vet with `make local-test` and `make local-lint`

#### Push feature/bugs-fix branch to remote repo:

  - Upon new branch creation, if change detected in `app` directory, GitHub Actions trigger `Test and Lint` workflow on  one of the GitHub runners

   ![remote test](/images/test2.png)

  - If test pass, then developer is to create PR to `main` with proper code review process that respect internally  (Assuming we follow [Trunk Base Development](https://trunkbaseddevelopment.com/) )
#### Semantic Versioning:
  - Once PR got approved and `Merged`, another workflow `Tag and Release` will be triggerd to
     * GitHub Actions will automatically create new Git tag with incremental value following [Semantic Versioning] (https://semver.org/) standards. Eg. v1.0.0 -> v1.0.1
     * GitHub Actions then create new Git Release

#### Build and publish to AWS ECR:

  - Log in to AWS ECR
  - Build the docker image
  - Pre-scanning on local image with `anchore`
  - Publish image to ECR after passing security scan
  - Publish scanning report back to GitHub via `codeql`


### Auto Deployment with Flux

> "GitOps is the best thing since configuration as code, Git changed how we collaborate, but declarative configration is the key to dealing with infrastructure as scale, and sets the stages for the next generation of management tools"  - Kelsey Hightower
>

In that spirit, `Flux` has been pre deployed on EKS cluster and configured to sync with `main` branch of this GitHub repo. 

The setup will then orcheatrate deployment process to kubernetes and commit change of that new image tag back to GitHub codebase.


The high level workflow as shown in below diagram:

![GitOps with FLUX](/images/image1.png)


Essentially, what flux does is to:

- Poll ECR status for the latest PUSH event
- Collect the latest image detail and deploy to EKS cluster
- Write image detail back to kubernetes manisfest to  Github repo and merge the change to `main` branch 


## Validate deployment on AWS EKS

### Prerequisites:
 - install kubectl
 - install jq
 - setup `kubeconfig` to access your own k8s environment 

Get loadbalancer DNS name

```sh
 kubectl get svc -o jsonpath='{.items[?(@.metadata.name=="anzx-test-b")].status.loadBalancer.ingress[0]}' | jq .

```
eg.
`a7c6776e3c2ea43f58335baa76a14ab5-196060278.ap-southeast-2.elb.amazonaws.com`

Validate the api endpoint

Example:

```sh
curl -Ss a7c6776e3c2ea43f58335baa76a14ab5-196060278.ap-southeast-2.elb.amazonaws.com:8080/version | jq .
```
API Example Response:

![respoonse](/images/response.png)
## Risks considerations
 - GitHub Action workflow running on public runners. we don't control infra of Action Runners where it is sharing public with other workflow. we have no visitbility of OS and Infrastructure config.

Recommandation: In enterpise environment, we should host our own runners in private subnets with one of Cloud service provider. Making sure the storage is encrypted. Also, restrict what this runners can do by assigning limited IAM permission to VM/Instances/Pods

- The service expose unsecured endpoint with http in public network. The traffic is unencrypted and open to the world.

Recommendation: if this intends to internal use, we should create ingress/elb in private subnet with TLS cert installed.
Also, we should setup API gateways in front of loadbalancer wich allows better control on auth, traffic control ,quotas and throttling.
In addition. it should configure to use API key or OIDC for authentication.

## License

[MIT](LICENSE)