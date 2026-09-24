# Day 49 – DevSecOps: Add Security to Your CI/CD Pipeline

## Task

Day 49 focused on adding security into the CI/CD pipeline instead of treating security as a separate step after deployment.

The original Day 48 pipeline could already build, test, push the Docker image, and deploy the application to AWS EC2. For Day 49, I extended that pipeline with automated security checks such as:

- Static Application Security Testing (SAST)
- Secret scanning
- Dependency vulnerability scanning
- Dependency review for pull requests
- Dockerfile linting
- Docker image vulnerability scanning with Trivy
- SARIF security reporting
- GitHub Actions permission hardening
- Action pinning using commit SHAs
- AWS OIDC authentication
- AWS Secrets Manager integration
- Security gates before Docker push and production deployment

The goal was to make security part of the pipeline itself.

---

## What is DevSecOps?

DevSecOps means integrating security into the existing development and CI/CD process.

Instead of:

```text
Developer
   ↓
Build
   ↓
Test
   ↓
Deploy
   ↓
Security team finds vulnerabilities
```

The idea is:

```text
Developer
   ↓
Pull Request
   ↓
Build + Test
   ↓
Security Scans
   ↓
Merge
   ↓
Docker Build
   ↓
Image Security Scan
   ↓
Docker Push
   ↓
Production Approval
   ↓
Production Deployment
```

In my own words:

> DevSecOps means making security an automated part of CI/CD. The pipeline continuously checks the source code, dependencies, secrets, Dockerfile, and final container image so that security problems can be detected before the application reaches production.

---

# Key Principles

The Day 49 task highlighted five important principles.

### 1. Catch problems early

A vulnerability found during a pull request is easier to fix than a vulnerability discovered after production deployment.

```text
PR
 ↓
Security Check
 ↓
Fix
 ↓
Merge
```

instead of:

```text
Deploy
 ↓
Security Problem
 ↓
Incident
 ↓
Fix Production
```

---

### 2. Automate security checks

Security checks should not depend on someone remembering to perform them manually.

The GitHub Actions pipeline automatically performs the required checks on every relevant workflow execution.

---

### 3. Block serious security issues

Security checks can act as gates.

For example, the Trivy scan is configured to fail when HIGH or CRITICAL vulnerabilities are detected.

```text
Docker Build
     ↓
Trivy Scan
     ↓
HIGH / CRITICAL?
   ↙       ↘
 YES       NO
  ↓         ↓
FAIL      CONTINUE
            ↓
       Docker Push
```

This prevents an image that fails the configured security policy from continuing to the next stage.

---

### 4. Never put secrets in source code

Application and infrastructure secrets should not be committed into Git.

For this project:

```text
GitHub Secrets / Variables
        +
AWS Secrets Manager
        ↓
Production Deployment
```

The production database password is stored in AWS Secrets Manager rather than inside the repository.

---

### 5. Give only the access needed

GitHub Actions workflows should not automatically receive unnecessary write permissions.

The project uses restricted permissions such as:

```yaml
permissions:
  contents: read
```

Security-sensitive jobs receive only the additional permission they require.

For example, SARIF upload jobs require:

```yaml
permissions:
  contents: read
  security-events: write
```

The production deployment workflow requires:

```yaml
permissions:
  id-token: write
  contents: read
```

This follows the principle of least privilege.

---

# My Day 49 Project

The trainer's task was based on the Day 48 CI/CD capstone.

For my implementation, I continued with my existing project:

```text
secure-cicd-pipeline-lab
```

GitHub repository:

```text
Aniruddhakharve/secure-cicd-pipeline-lab
```

The project is a small Flask + MySQL application deployed through Docker Compose to an AWS EC2 production server.

The project evolved through several stages:

```text
Three-Tier Application
        ↓
NodeGoat DevSecOps Practice
        ↓
Secure CI/CD Pipeline Lab
        ↓
DevSecOps Pipeline
```

Day 49 was therefore not just a single Trivy command. I used the existing CI/CD pipeline and added multiple security controls around it.

---

# Project Architecture

The application contains:

```text
Flask Application
       ↓
Docker Container
       ↓
MySQL Container
```

Production:

```text
GitHub
   │
   │ Push / Pull Request
   ↓
GitHub Actions
   │
   ├── Lint
   ├── Build & Test
   ├── SAST
   ├── Secret Scan
   ├── Dependency Scan
   ├── Dependency Review
   ├── Dockerfile Lint
   │
   └── Docker Build
           │
           ↓
      Trivy Scan
           │
           ↓
      Docker Push
           │
           ↓
   Production Approval
           │
           ↓
     GitHub OIDC
           │
           ↓
       AWS STS
           │
           ↓
        IAM Role
           │
           ↓
       AWS SSM
           │
           ↓
        EC2 Server
           │
           ↓
   Docker Compose
           │
       ┌───┴───┐
       ↓       ↓
     Flask   MySQL
```

---

# Day 49 Security Pipeline

My final pipeline contains two main paths.

## Pull Request Pipeline

```text
Pull Request
     ↓
Lint
     ↓
Build + Test
     ↓
SAST
     ↓
Secret Scan
     ↓
Dependency Scan
     ↓
Dependency Review
     ↓
Dockerfile Lint
     ↓
PR Validation
```

The PR pipeline does not push an application image or deploy to production.

---

## Main Pipeline

```text
Push to main
     ↓
Lint
     │
     ├───────────────┬───────────────┬───────────────┐
     ↓               ↓               ↓               ↓
 Build/Test         SAST        Secret Scan    Dependency Scan
     │                                               │
     └───────────────┬───────────────────────────────┘
                     ↓
              Dockerfile Lint
                     ↓
               Docker Build
                     ↓
               Save Image
                     ↓
             Trivy Image Scan
                     ↓
              Security Gate
                     ↓
              Docker Push
                     ↓
          Production Approval
                     ↓
              AWS OIDC / STS
                     ↓
                  AWS SSM
                     ↓
          Secrets Manager
                     ↓
               EC2 Deploy
                     ↓
             Health Check
```

---

# Challenge Task 1 – Scan Docker Image for Vulnerabilities

## Why Docker Image Scanning?

A Docker image contains more than my application code.

It contains:

```text
Application
+
Python
+
Python packages
+
Operating System packages
+
Base image
```

Any of these components can contain known vulnerabilities.

Therefore, building an image successfully does not automatically mean that the image is secure.

---

# Trivy

I used Trivy to scan the final Docker image for known vulnerabilities.

Trivy can identify vulnerabilities in:

- OS packages
- Application libraries
- Container images
- Dependencies

The important part of my configuration was:

```yaml
severity: CRITICAL,HIGH
exit-code: 1
vuln-type: os,library
```

The security policy is therefore:

```text
CRITICAL → fail
HIGH     → fail
MEDIUM   → allowed
LOW      → allowed
```

---

# Trivy in My Pipeline

The important difference in my implementation is that I did not simply rebuild the image inside the Trivy job.

I used a:

```text
Build Once → Scan Same Image → Push Same Image
```

architecture.

The flow is:

```text
Docker Build
     ↓
docker save
     ↓
Artifact
     ↓
Trivy Job
     ↓
docker load
     ↓
Trivy Scan
     ↓
Docker Push
```

This guarantees that the image being scanned is the same image that is eventually pushed.

---

# Why Build Once and Scan the Same Image?

Suppose the pipeline did this:

```text
Build Image A
     ↓
Scan Image B
     ↓
Push Image C
```

There is no guarantee that the scanned artifact is the artifact that reaches production.

My pipeline instead follows:

```text
Build Image A
     ↓
Save Image A
     ↓
Scan Image A
     ↓
Push Image A
```

This gives the pipeline artifact integrity from build through deployment.

---

# Docker Image Tag

The application image uses the full Git commit SHA:

```yaml
image_tag: ${{ github.sha }}
```

For example:

```text
aniruddhakharve/secure-cicd-pipeline-lab:<full-git-sha>
```

I intentionally use the full commit SHA instead of:

```text
latest
```

This makes every application image traceable to the exact source commit that produced it.

---

# Important Difference: GitHub SHA vs Docker Compose Variable

Inside GitHub Actions:

```yaml
${{ github.sha }}
```

is a GitHub Actions expression.

It is evaluated by GitHub Actions.

Inside Docker Compose:

```yaml
${IMAGE_TAG}
```

is an environment-variable expression evaluated by Docker Compose.

During deployment, the actual `.env` file contains the concrete SHA:

```text
IMAGE_TAG=<full-git-sha>
```

So the flow is:

```text
GitHub Commit
     ↓
github.sha
     ↓
IMAGE_TAG
     ↓
Docker Compose
     ↓
Exact application image
```

---

# Trivy SARIF Reporting

I also configured Trivy to generate SARIF output.

SARIF allows security scan results to be integrated with GitHub's security tooling.

The general flow is:

```text
Trivy
  ↓
SARIF file
  ↓
GitHub Code Scanning / Security
```

The SARIF upload requires:

```yaml
permissions:
  contents: read
  security-events: write
```

The `security-events: write` permission is therefore granted only to the job that needs it.

---

# Trivy Severity Filtering Problem

One important issue I encountered was related to SARIF severity filtering.

The Trivy scan was configured for:

```text
CRITICAL,HIGH
```

However, the SARIF output initially did not behave exactly like the table output.

I therefore used:

```yaml
limit-severities-for-sarif: true
```

This ensures that the SARIF report is limited to the configured severities.

Final concept:

```text
Trivy Scan
    │
    ├── Table / scan result
    │
    └── SARIF
          ↓
    HIGH + CRITICAL
```

---

# Trivy Base Image Learning

I also compared base-image behavior during the project.

A base image can significantly affect the vulnerability results of the final image.

For example:

```dockerfile
FROM python:3.12-alpine
```

uses Alpine Linux as the base image.

This helped demonstrate an important DevSecOps concept:

> The security of the final container image is affected by the components inherited from its base image.

Therefore, choosing and regularly updating the base image is part of container security.

---

# Challenge Task 2 – Secret Scanning

## What is Secret Scanning?

Secret scanning detects credentials or sensitive tokens accidentally committed to a repository.

Examples include:

```text
AWS Access Keys
API Keys
GitHub Tokens
Database Passwords
Private Tokens
Cloud Credentials
```

A secret accidentally committed to Git can remain in Git history even after the visible line is deleted.

Therefore:

```text
Do not commit the secret
```

is much better than:

```text
Commit secret
↓
Delete secret later
```

---

# GitHub Secret Scanning

GitHub provides built-in secret scanning for repositories where the feature is available.

The purpose is to detect secrets that appear in repository content.

For this project, the security design also avoids putting production database credentials directly into the repository.

---

# Secret Scanning vs Push Protection

These concepts are related but different.

## Secret Scanning

Secret scanning detects potential leaked credentials in repository content.

```text
Secret appears in repository
        ↓
GitHub detects it
```

## Push Protection

Push protection can prevent the secret from being pushed in the first place.

```text
Developer attempts push
        ↓
Secret detected
        ↓
Push blocked
```

Therefore:

```text
Secret Scanning
= Detect leaked secrets

Push Protection
= Prevent secret from being pushed
```

---

# Gitleaks in My Pipeline

In addition to GitHub's built-in capabilities, I added automated secret scanning to the CI pipeline using Gitleaks.

The reusable secret-scan workflow checks the repository for exposed secrets.

The checkout uses:

```yaml
fetch-depth: 0
```

This allows the scanner to inspect the complete Git history rather than only the latest commit.

The pipeline therefore has:

```text
Git Repository
      ↓
Gitleaks
      ↓
Potential Secret?
    ↙       ↘
  YES       NO
   ↓         ↓
 FAIL      PASS
```

---

# Why Secrets Are Not Stored in the Repository

The production MySQL credentials are not hardcoded in:

```text
docker-compose.yml
```

or:

```text
.env
```

inside the Git repository.

Instead:

```text
AWS Secrets Manager
        ↓
EC2 deployment
        ↓
.env created on EC2
        ↓
Docker Compose
        ↓
MySQL
```

The repository contains the configuration structure, while the sensitive production values remain outside Git.

---

# AWS Secrets Manager

The production secret is stored under:

```text
secure-cicd-pipeline-lab/production
```

The secret contains:

```text
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD
```

The EC2 instance retrieves the secret during deployment.

The GitHub Actions workflow does not need to contain the actual database password.

---

# Challenge Task 3 – Dependency Vulnerability Scanning

Application dependencies can contain known vulnerabilities even when the application code itself is written correctly.

For the Flask application, dependencies are defined in:

**`requirements.txt`**

```text
Flask
pytest
mysql-connector-python
```

I added dependency scanning using `pip-audit`.

The scan checks Python packages against known vulnerability information.

The workflow produces:

```text
Dependency Scan
      ↓
pip-audit
      ↓
Vulnerability Report
```

The reusable workflow generates both human-readable and JSON output.

---

# Dependency Scan vs Dependency Review

These two concepts are easy to confuse.

## Dependency Scan

My dependency scan checks the application's Python dependencies.

```text
requirements.txt
      ↓
pip-audit
      ↓
Known vulnerabilities
```

It is concerned with the dependencies used by the application.

---

## Dependency Review

Dependency Review is used in the Pull Request pipeline.

It evaluates dependency changes introduced by a PR.

The configuration uses:

```yaml
fail-on-severity: critical
```

The important difference is:

```text
Dependency Scan
= Scan application dependencies

Dependency Review
= Review dependency changes introduced by a PR
```

---

# Dependency Review PR Flow

```text
Developer
    ↓
Creates PR
    ↓
Dependency Review
    ↓
New dependency has critical vulnerability?
       ↙              ↘
     YES              NO
      ↓                ↓
   PR fails          PR continues
```

This is useful because dependency changes can be checked before they are merged into `main`.

---

# Challenge Task 4 – Workflow Permissions

GitHub Actions permissions determine what the workflow is allowed to access through the GitHub token.

Instead of allowing broad access, I use:

```yaml
permissions:
  contents: read
```

This means the workflow can read repository contents without automatically receiving unnecessary write permissions.

---

# Job-Level Permissions

Different jobs need different permissions.

For example, the SAST job uploads SARIF results:

```yaml
permissions:
  contents: read
  security-events: write
```

The Trivy job also uploads SARIF:

```yaml
permissions:
  contents: read
  security-events: write
```

The production deployment job uses OIDC:

```yaml
permissions:
  id-token: write
  contents: read
```

This is an example of least privilege.

---

# Why Least Privilege Matters

Suppose a malicious or compromised GitHub Action had unnecessary write access.

It could potentially perform actions that the job never actually needed.

Therefore:

```text
More permissions
       ↓
Larger attack surface
```

while:

```text
Minimum required permissions
       ↓
Smaller attack surface
```

The goal is not to give every workflow maximum access.

The goal is:

> Give each job only the permissions required for its specific task.

---

# Action Pinning to Commit SHAs

The trainer listed action pinning as an optional brownie-point task.

I implemented this concept extensively in my project.

Instead of relying only on a mutable tag:

```yaml
uses: actions/checkout@v4
```

the workflow uses a specific commit SHA:

```yaml
uses: actions/checkout@<commit-sha> # version reference
```

The same approach is used for important third-party and GitHub Actions throughout the reusable workflows.

---

# Why Pin Actions?

A GitHub Action referenced using a tag can potentially change when the tag is moved.

Using a commit SHA makes the dependency immutable for that workflow reference.

Conceptually:

```text
Mutable tag
   ↓
Action version can change

Commit SHA
   ↓
Exact action commit
```

This reduces supply-chain risk from unexpected action changes.

---

# Reusable Workflows

Instead of placing every security step directly into one huge workflow, I separated the pipeline into reusable workflows.

Important reusable workflows include:

```text
reusable-lint.yml
reusable-build-test.yml
reusable-sast.yml
reusable-secret-scan.yml
reusable-dependency-scan.yml
reusable-dependency-review.yml
reusable-dockerfile-lint.yml
reusable-docker-build.yml
reusable-trivy-scan.yml
reusable-docker-push.yml
reusable-production-deploy.yml
```

The main pipeline calls these reusable workflows.

This keeps the main pipeline easier to understand and allows individual stages to be maintained independently.

---

# Static Application Security Testing – SAST

SAST means:

```text
Static Application Security Testing
```

It analyzes source code without executing the application.

I used Semgrep for SAST.

The workflow runs:

```text
Source Code
    ↓
Semgrep
    ↓
Security Findings
    ↓
SARIF
    ↓
GitHub Security
```

The Semgrep configuration uses:

```text
semgrep scan --config=auto --sarif
```

This adds source-code security analysis to the pipeline.

---

# SAST vs Trivy

These are not the same scan.

## SAST

Looks at:

```text
Application Source Code
```

Example:

```text
Python code
    ↓
Semgrep
```

## Trivy

Looks at:

```text
Container Image
OS Packages
Application Libraries
```

Example:

```text
Docker Image
    ↓
Trivy
```

Therefore:

```text
SAST
= Source-code security

Trivy
= Container / dependency vulnerability scanning
```

Using both gives broader coverage.

---

# Dockerfile Linting

The Dockerfile itself can contain configuration problems or insecure practices.

I added Hadolint to the pipeline.

Flow:

```text
Dockerfile
    ↓
Hadolint
    ↓
Lint / Best-Practice Findings
```

This is different from Trivy.

```text
Hadolint
= Dockerfile quality / best practices

Trivy
= Vulnerability scanning
```

---

# Application Security Headers

As part of the secure application implementation, I also added HTTP security headers to the Flask application.

The application sets headers such as:

```text
Content-Security-Policy
X-Content-Type-Options
X-Frame-Options
Referrer-Policy
Permissions-Policy
```

For example:

```python
response.headers["X-Content-Type-Options"] = "nosniff"
response.headers["X-Frame-Options"] = "DENY"
```

The application also uses a Content Security Policy.

This demonstrates that DevSecOps is not limited to scanning tools.

Security can also be implemented directly in the application.

---

# GitHub OIDC – Keyless Authentication

The trainer listed OIDC as an optional topic.

I went further and used OIDC for the production deployment.

Instead of storing a long-lived AWS access key and secret key inside GitHub:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

GitHub Actions obtains a short-lived identity token.

The flow is:

```text
GitHub Actions
      ↓
OIDC Token
      ↓
AWS STS
      ↓
Assume IAM Role
      ↓
Temporary AWS Credentials
      ↓
AWS Services
```

---

# OIDC → STS → IAM

This was an important concept from the project.

### Step 1 – GitHub creates an OIDC identity token

The workflow requests:

```yaml
permissions:
  id-token: write
```

### Step 2 – AWS receives the identity

AWS trusts GitHub's OIDC provider.

### Step 3 – AWS STS validates the token

STS means:

```text
Security Token Service
```

### Step 4 – STS issues temporary credentials

The workflow receives temporary credentials associated with the IAM role.

### Step 5 – AWS permissions are applied

The assumed role determines what the workflow can do.

Therefore:

```text
GitHub
  ↓
OIDC
  ↓
STS
  ↓
IAM Role
  ↓
Temporary Credentials
  ↓
AWS
```

No long-lived AWS access key is required for this deployment workflow.

---

# Final IAM Architecture

The final project uses two IAM roles.

## Role 1 – GitHub Actions Production Deploy

```text
GitHubActions-Production-Deploy
```

Purpose:

```text
GitHub Actions
      ↓
OIDC
      ↓
AWS IAM Role
      ↓
SSM
      ↓
Production EC2
```

This role allows the GitHub Actions workflow to send the required SSM commands to the production EC2 instance.

---

## Role 2 – EC2 SSM Role

```text
ProductionEC2-SSM-Role
```

Purpose:

```text
EC2
 ↓
SSM Agent
 ↓
AWS permissions
```

The EC2 instance uses this role to communicate with AWS Systems Manager.

It also has permission to retrieve the required production secret from AWS Secrets Manager.

---

# No Third IAM Role

The final architecture does not require a third IAM role.

The two required roles are:

```text
1. GitHubActions-Production-Deploy
2. ProductionEC2-SSM-Role
```

They have different responsibilities.

```text
GitHub Actions Role
= Allows CI/CD workflow to interact with AWS

EC2 Role
= Allows EC2 to interact with AWS
```

---

# AWS Systems Manager – SSM

The production deployment does not require SSH keys.

Instead:

```text
GitHub Actions
      ↓
AWS SSM
      ↓
EC2
```

The workflow sends commands through Systems Manager.

The production EC2 instance is registered with SSM and the SSM Agent is online.

---

# Why SSM Instead of SSH?

The deployment can be performed without storing:

```text
SSH private key
```

inside GitHub.

Instead:

```text
GitHub OIDC
     ↓
IAM
     ↓
SSM
     ↓
EC2
```

This keeps the deployment authentication integrated with AWS IAM.

---

# Production Deployment

The reusable production deployment workflow receives the exact image tag:

```yaml
with:
  image-tag: ${{ github.sha }}
```

The deployment then creates the production environment configuration on EC2.

The `.env` file contains values such as:

```text
DOCKER_USERNAME
IMAGE_TAG
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD
```

The database values come from AWS Secrets Manager.

---

# Exact Docker Compose File Deployment

Another important part of the final architecture is that production uses the Docker Compose file from the exact commit being deployed.

Conceptually:

```text
GitHub Commit SHA
       ↓
Exact docker-compose.yml
       ↓
EC2
       ↓
Docker Compose
```

This prevents production from accidentally using a different version of the deployment configuration.

---

# Production Compose Architecture

The production Compose file uses an image rather than building the application on the EC2 server.

Application service:

```yaml
image: ${DOCKER_USERNAME}/secure-cicd-pipeline-lab:${IMAGE_TAG}
```

This means EC2 performs:

```text
docker compose pull
```

instead of:

```text
docker compose build
```

The production server therefore consumes the already-built image from Docker Hub.

---

# Production Image Flow

```text
Git Commit
    ↓
GitHub Actions
    ↓
Docker Build
    ↓
Exact Image
    ↓
Artifact
    ↓
Trivy
    ↓
Security Gate
    ↓
Docker Hub
    ↓
EC2
    ↓
docker compose pull
    ↓
Production
```

The image is not rebuilt on EC2.

---

# MySQL Persistence

The production MySQL container uses a named Docker volume:

```yaml
volumes:
  - mysql-data:/var/lib/mysql
```

The deployment intentionally uses:

```bash
docker compose down
```

and not:

```bash
docker compose down -v
```

because removing the volume would remove the persistent database storage.

Therefore:

```text
Container
   ↓
Can be recreated

Named Volume
   ↓
Persists database data
```

This is important for production deployments.

---

# MySQL Health Check

The MySQL service has a Docker health check:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 5s
  timeout: 5s
  retries: 10
```

The Flask application depends on MySQL being healthy:

```yaml
depends_on:
  mysql:
    condition: service_healthy
```

Therefore:

```text
MySQL
  ↓
Health Check
  ↓
Healthy
  ↓
Flask Application Starts
```

---

# Production Health Check

After deployment, the pipeline verifies the application using:

```bash
curl -fsS http://localhost:5000/health
```

Expected response:

```json
{
  "database": "connected",
  "status": "healthy"
}
```

This verifies not only that the container is running, but also that the application can communicate with MySQL.

---

# SSM Result Handling Lesson

One important problem I encountered was understanding SSM command output.

Docker Compose can write normal progress information to stderr.

Therefore, seeing content in the SSM `Error` field does not automatically mean the deployment failed.

The workflow therefore checks the actual SSM command status and response code.

The important logic is:

```text
SSM Status
    +
Response Code
    ↓
Actual Success / Failure
```

This avoids incorrectly treating normal Compose output as a deployment failure.

---

# GitHub Actions Job Outputs

The reusable workflows expose results through outputs.

For example:

```yaml
outputs:
  trivy_result:
    description: "Trivy scan result"
    value: ${{ jobs.trivy-scan.outputs.trivy_result }}
```

The main pipeline can then consume the output:

```yaml
${{ needs.trivy-scan.outputs.trivy_result }}
```

This makes the reusable workflow communicate its result back to the calling workflow.

---

# Important GitHub Actions Concepts Used

Day 49 helped reinforce several GitHub Actions concepts.

## `needs`

Controls job dependency.

Example:

```yaml
trivy-scan:
  needs:
    - docker-build
```

Meaning:

```text
docker-build
     ↓
trivy-scan
```

---

## `if`

Controls whether a step or job executes.

It is useful for conditions and final result handling.

---

## `env`

Provides environment variables to a step or job.

Example:

```yaml
env:
  IMAGE_TAG: ${{ github.sha }}
```

---

## `id`

Provides an identifier for a step.

Example:

```yaml
id: deployment_result
```

The output can then be referenced.

---

## `$GITHUB_OUTPUT`

Used to create step outputs.

Example:

```bash
echo "deployment_result=passed" >> "$GITHUB_OUTPUT"
```

---

## `permissions`

Controls the GitHub token permissions available to a workflow or job.

Example:

```yaml
permissions:
  contents: read
```

---

# Important Problems Encountered

## Problem 1 – Trivy Image Vulnerability Findings

The initial container image choice produced vulnerability findings during image scanning.

This demonstrated that:

```text
Application code can be correct
```

while:

```text
Container image can still contain vulnerabilities
```

### Lesson

Container security requires scanning the final image, not just testing application code.

---

## Problem 2 – Trivy SARIF Severity Handling

The SARIF output initially did not behave exactly like the expected HIGH/CRITICAL filtering.

### Solution

The Trivy configuration was adjusted to include:

```yaml
limit-severities-for-sarif: true
```

### Lesson

The format of a security report can affect how findings are represented. Scan configuration needs to be verified for each output format.

---

## Problem 3 – Understanding Build Once vs Rebuild

Initially, it was easy to think:

```text
Build image
↓
Scan image
↓
Build image again
↓
Push
```

would be acceptable.

The better architecture is:

```text
Build once
↓
Save exact image
↓
Scan exact image
↓
Push exact image
```

### Lesson

The artifact that gets scanned should be the same artifact that gets promoted.

---

## Problem 4 – GitHub Permissions

Security-related jobs do not all need the same permissions.

For example:

```text
Normal workflow
→ contents: read

SARIF upload
→ security-events: write

AWS OIDC
→ id-token: write
```

### Lesson

Permissions should be granted at the smallest required scope.

---

## Problem 5 – SSM Error Field

Compose output appearing in SSM's error stream was initially confusing.

### Solution

The deployment checks:

```text
SSM Status
+
Response Code
```

instead of treating every stderr message as failure.

### Lesson

Always understand how the underlying execution system reports stdout, stderr, status, and exit codes.

---

## Problem 6 – Production Image vs Build

Production should not rebuild the application image on the EC2 server.

The final architecture uses:

```yaml
image:
  ${DOCKER_USERNAME}/secure-cicd-pipeline-lab:${IMAGE_TAG}
```

and:

```bash
docker compose pull
```

### Lesson

CI builds and validates the artifact.

Production consumes the validated artifact.

---

# Common Confusions

## Confusion 1 – Secret Scanning vs Dependency Scanning

They solve different problems.

```text
Secret Scan
→ Finds leaked credentials

Dependency Scan
→ Finds vulnerable packages
```

---

## Confusion 2 – Dependency Review vs pip-audit

```text
Dependency Review
→ PR dependency changes

pip-audit
→ Python package vulnerabilities
```

---

## Confusion 3 – SAST vs Trivy

```text
SAST
→ Source code

Trivy
→ Container image / OS packages / libraries
```

---

## Confusion 4 – Hadolint vs Trivy

```text
Hadolint
→ Dockerfile linting

Trivy
→ Vulnerability scanning
```

---

## Confusion 5 – OIDC vs Secrets Manager

These solve completely different problems.

### OIDC

Used for:

```text
GitHub Actions
      ↓
AWS authentication
```

### Secrets Manager

Used for:

```text
Secure application secrets
```

Therefore:

```text
OIDC
= How GitHub authenticates to AWS

Secrets Manager
= Where production secrets are stored
```

---

## Confusion 6 – OIDC vs STS

OIDC provides the identity token.

STS exchanges that trusted identity for temporary AWS credentials.

```text
GitHub OIDC
    ↓
AWS STS
    ↓
Temporary Credentials
```

---

## Confusion 7 – GitHub Secret vs AWS Secret

GitHub Secrets are useful for values required by GitHub Actions.

AWS Secrets Manager is useful for application/runtime secrets managed inside AWS.

In this project, production database credentials are stored in AWS Secrets Manager and retrieved during deployment.

---

## Confusion 8 – Docker Image vs Docker Container

```text
Docker Image
= Immutable package/template

Docker Container
= Running instance of the image
```

The CI pipeline builds and scans the image.

The EC2 server runs the container from that image.

---

# Full Secure Pipeline

## Pull Request

```text
Developer
    ↓
Pull Request
    ↓
┌─────────────────────────────┐
│ Lint                        │
│ Build + Test                │
│ SAST                        │
│ Secret Scan                 │
│ Dependency Scan             │
│ Dependency Review           │
│ Dockerfile Lint             │
└─────────────────────────────┘
    ↓
PR Validation
```

---

## Merge to Main

```text
Push to main
      ↓
┌─────────────────────────────┐
│ Lint                        │
│ Build + Test                │
│ SAST                        │
│ Secret Scan                 │
│ Dependency Scan             │
│ Dockerfile Lint             │
└─────────────────────────────┘
      ↓
Docker Build
      ↓
Save Exact Image
      ↓
Upload Artifact
      ↓
Download Artifact
      ↓
Load Exact Image
      ↓
Trivy Scan
      ↓
Security Gate
      ↓
Docker Push
      ↓
Production Approval
      ↓
OIDC
      ↓
AWS STS
      ↓
IAM Role
      ↓
SSM
      ↓
EC2
      ↓
Secrets Manager
      ↓
Docker Compose
      ↓
Health Check
```

---

# Final DevSecOps Architecture

```text
                         GitHub
                            │
             ┌──────────────┴──────────────┐
             │                             │
          Pull Request                  main push
             │                             │
             ↓                             ↓
       PR Pipeline                    Main Pipeline
             │                             │
    ┌────────┴────────┐          ┌─────────┴─────────┐
    │                 │          │                   │
  Build/Test        Security   Build/Test          Security
                      Checks                         Checks
    │                 │          │                   │
    └────────┬────────┘          └─────────┬─────────┘
             │                             │
             ↓                             ↓
         PR Gate                       Docker Build
                                           │
                                           ↓
                                      Image Artifact
                                           │
                                           ↓
                                       Trivy Scan
                                           │
                                  ┌────────┴────────┐
                                  │                 │
                                FAIL              PASS
                                  │                 │
                                  X                 ↓
                                              Docker Push
                                                   │
                                                   ↓
                                          Production Approval
                                                   │
                                                   ↓
                                                OIDC
                                                   │
                                                   ↓
                                                 STS
                                                   │
                                                   ↓
                                             IAM Role
                                                   │
                                                   ↓
                                                 SSM
                                                   │
                                                   ↓
                                                EC2
                                                   │
                                ┌──────────────────┴─────────────────┐
                                │                                    │
                              Flask                                MySQL
                                │                                    │
                                └──────────────┬─────────────────────┘
                                               │
                                               ↓
                                         Health Check
```

---

# Important Files

The important project files involved in Day 49 include:

**`.github/workflows/main-pipeline.yml`**

Controls the main CI/CD pipeline.

**`.github/workflows/pr-pipeline.yml`**

Controls pull request validation.

**`.github/workflows/reusable-lint.yml`**

Runs code linting.

**`.github/workflows/reusable-build-test.yml`**

Runs application tests.

**`.github/workflows/reusable-sast.yml`**

Runs Semgrep SAST and uploads SARIF results.

**`.github/workflows/reusable-secret-scan.yml`**

Runs Gitleaks.

**`.github/workflows/reusable-dependency-scan.yml`**

Runs dependency vulnerability scanning with pip-audit.

**`.github/workflows/reusable-dependency-review.yml`**

Checks dependency changes in pull requests.

**`.github/workflows/reusable-dockerfile-lint.yml`**

Runs Hadolint.

**`.github/workflows/reusable-docker-build.yml`**

Builds the Docker image and stores the exact image as an artifact.

**`.github/workflows/reusable-trivy-scan.yml`**

Loads and scans the exact Docker image using Trivy.

**`.github/workflows/reusable-docker-push.yml`**

Pushes the validated image to Docker Hub.

**`.github/workflows/reusable-production-deploy.yml`**

Handles production deployment through AWS OIDC, SSM, Secrets Manager, Docker Compose, and health checks.

**`Dockerfile`**

Defines the application container image.

**`docker-compose.yml`**

Defines the production application and MySQL services.

**`requirements.txt`**

Defines Python dependencies.

**`app/app.py`**

Contains the Flask application and security headers.

**`tests/test_app.py`**

Contains application tests.

**`.dockerignore`**

Prevents unnecessary files from being included in the Docker build context.

---

# Interview Questions & Answers

## 1. What is DevSecOps?

**Answer:**

> DevSecOps means integrating security into the software development and CI/CD lifecycle. Instead of checking security only after deployment, we automate security checks such as SAST, secret scanning, dependency scanning, Dockerfile linting, and container vulnerability scanning inside the pipeline.

---

## 2. Why do you scan Docker images?

**Answer:**

> A Docker image contains the application, libraries, operating system packages, and the base image. Even if the application code passes all tests, the image can still contain known CVEs. Therefore, I use Trivy to scan the final image before pushing it to Docker Hub.

---

## 3. Why did you use `exit-code: 1` with Trivy?

**Answer:**

> The exit code controls whether the pipeline fails when vulnerabilities matching the configured severity are found. I configured Trivy for HIGH and CRITICAL vulnerabilities with exit code 1 so that the security scan acts as a gate before Docker push.

---

## 4. What is a CVE?

**Answer:**

> CVE stands for Common Vulnerabilities and Exposures. It is a standardized identifier for publicly known security vulnerabilities.

---

## 5. What is the difference between SAST and container scanning?

**Answer:**

> SAST analyzes the application source code for security issues without running the application. Container scanning analyzes the built container image and its operating system packages and libraries for known vulnerabilities. In my pipeline I use Semgrep for SAST and Trivy for container scanning.

---

## 6. What is secret scanning?

**Answer:**

> Secret scanning detects credentials such as API keys, tokens, or passwords that may have been accidentally committed to a repository. I also use Gitleaks in the CI pipeline to detect exposed secrets.

---

## 7. What is push protection?

**Answer:**

> Push protection can prevent a detected secret from being pushed to the repository in the first place. Secret scanning primarily detects leaked secrets, while push protection can block the push before the secret reaches the repository.

---

## 8. What is dependency scanning?

**Answer:**

> Dependency scanning checks application dependencies against known vulnerability databases. In my Python project I use pip-audit to identify vulnerable Python packages.

---

## 9. What is Dependency Review?

**Answer:**

> Dependency Review is used in pull requests to review dependency changes introduced by the PR. In my pipeline I configured it to fail when a newly introduced dependency has a critical severity vulnerability.

---

## 10. Why use `permissions: contents: read`?

**Answer:**

> It follows the principle of least privilege. The workflow usually only needs to read the repository, so giving it write access would unnecessarily increase the impact of a compromised workflow or action.

---

## 11. Why does the SAST job need `security-events: write`?

**Answer:**

> The SAST workflow uploads SARIF security results to GitHub. Therefore, it needs permission to write security events.

---

## 12. Why does the production deployment job need `id-token: write`?

**Answer:**

> The workflow uses GitHub OIDC to authenticate to AWS. The `id-token: write` permission allows GitHub Actions to request the OIDC token required for AWS role assumption.

---

## 13. Explain OIDC in your project.

**Answer:**

> GitHub Actions requests an OIDC identity token, AWS trusts GitHub's OIDC provider, and AWS STS validates the token and allows the workflow to assume the GitHubActions-Production-Deploy IAM role. The workflow receives temporary AWS credentials instead of using long-lived AWS access keys.

---

## 14. What is the difference between OIDC and Secrets Manager?

**Answer:**

> OIDC handles authentication between GitHub Actions and AWS. Secrets Manager stores sensitive application values such as production database credentials. They solve different problems.

---

## 15. Why did you use AWS SSM?

**Answer:**

> I used Systems Manager to execute deployment commands on the EC2 instance without storing SSH private keys in GitHub. GitHub Actions authenticates to AWS using OIDC and then uses the IAM permissions to send commands through SSM.

---

## 16. How do you deploy the exact image that was scanned?

**Answer:**

> I build the Docker image once using the full Git SHA as the tag. I save that exact image as an artifact, load it in the Trivy job, scan it, and then push the same image if the scan passes. This gives me a Build Once, Scan Same Image, Push Same Image flow.

---

## 17. Why use the Git SHA as the Docker tag?

**Answer:**

> The full Git SHA uniquely identifies the source commit that produced the image. It gives traceability between source code, Docker image, CI pipeline, and production deployment.

---

## 18. Why don't you use `latest`?

**Answer:**

> `latest` is mutable and does not uniquely identify the source version. A full Git SHA provides an immutable and traceable reference to the commit that created the image.

---

## 19. Why don't you build the image directly on EC2?

**Answer:**

> The CI pipeline builds, tests, scans, and pushes the image. Production then pulls that already-validated image. This separates build from deployment and ensures that production runs the artifact that passed the security checks.

---

## 20. Why use a named Docker volume for MySQL?

**Answer:**

> The named volume keeps MySQL data separate from the container lifecycle. The application containers can be recreated during deployment while the database data remains persistent.

---

## 21. Why don't you use `docker compose down -v`?

**Answer:**

> The `-v` option removes named volumes. Since the MySQL database uses a named volume for persistent storage, removing it would delete the database data. Therefore, I use `docker compose down` without `-v`.

---

## 22. What is SARIF?

**Answer:**

> SARIF stands for Static Analysis Results Interchange Format. Security tools can generate SARIF reports that GitHub can ingest and display through its security features.

---

## 23. Why pin GitHub Actions to commit SHAs?

**Answer:**

> Tags such as `@v4` can move to another commit. Pinning an action to a commit SHA ensures that the workflow uses a specific action revision and reduces supply-chain risk from unexpected action changes.

---

## 24. What is the principle of least privilege?

**Answer:**

> Least privilege means giving a user, workflow, or service only the permissions required to perform its task and no unnecessary permissions.

---

# How to Explain Day 49 in an Interview

A concise explanation:

> "For Day 49, I integrated DevSecOps into my CI/CD pipeline. I added Semgrep for SAST, Gitleaks for secret scanning, pip-audit and Dependency Review for dependency security, Hadolint for Dockerfile linting, and Trivy for container image vulnerability scanning. I configured security gates so the Docker image is not pushed when HIGH or CRITICAL vulnerabilities are found. I also implemented least-privilege GitHub Actions permissions and pinned actions to commit SHAs. For production deployment, I used GitHub OIDC with AWS STS instead of long-lived AWS credentials, SSM for remote EC2 execution, and AWS Secrets Manager for production database credentials. The key architecture is Build Once → Scan Same Image → Push Same Image → Deploy the exact validated image."

---

# Short Interview Version

If the interviewer asks:

**"What did you implement in your DevSecOps pipeline?"**

Answer:

> "I integrated security checks throughout the CI/CD lifecycle. PRs run linting, tests, SAST, secret scanning, dependency scanning, dependency review, and Dockerfile linting. On the main branch, the application image is built once, saved as an artifact, scanned with Trivy for HIGH and CRITICAL vulnerabilities, and only then pushed to Docker Hub. Production deployment uses GitHub OIDC, AWS STS, IAM, SSM, and Secrets Manager, and the deployment ends with an application health check."

---

# Hands-on Scenarios

## Scenario 1 – Developer Accidentally Commits a Secret

```text
Developer
    ↓
Push / PR
    ↓
Gitleaks / Secret Scanning
    ↓
Secret detected
    ↓
Pipeline / protection blocks or reports it
```

The developer should remove the secret and rotate the compromised credential.

---

## Scenario 2 – A New Dependency Has a Critical Vulnerability

```text
Developer adds dependency
        ↓
Pull Request
        ↓
Dependency Review
        ↓
Critical vulnerability
        ↓
PR check fails
```

The dependency should be reviewed before merging.

---

## Scenario 3 – Docker Image Contains a HIGH CVE

```text
Docker Build
     ↓
Trivy
     ↓
HIGH vulnerability
     ↓
Exit code 1
     ↓
Pipeline fails
     ↓
Docker Push does not run
```

This is a security gate.

---

## Scenario 4 – Source Code Contains a Security Issue

```text
Pull Request
     ↓
Semgrep
     ↓
Security finding
     ↓
SAST result
     ↓
Review / Fix
```

The issue can be addressed before the code reaches production.

---

## Scenario 5 – Production Database Password

The password should not be committed like:

```text
MYSQL_PASSWORD=my-production-password
```

Instead:

```text
AWS Secrets Manager
        ↓
SSM Deployment
        ↓
Production .env
        ↓
Docker Compose
```

---

## Scenario 6 – GitHub Action Needs Security Permission

Instead of:

```yaml
permissions:
  write-all
```

use the smallest required permission:

```yaml
permissions:
  contents: read
  security-events: write
```

only for the job that uploads SARIF results.

---

## Scenario 7 – Production Deployment Authentication

Instead of:

```text
GitHub
 ↓
AWS Access Key
 ↓
AWS
```

the project uses:

```text
GitHub
 ↓
OIDC
 ↓
AWS STS
 ↓
IAM Role
 ↓
Temporary Credentials
 ↓
SSM
 ↓
EC2
```

---

# Quick Revision Cheat Sheet

## DevSecOps

```text
Security + Development + Operations
```

---

## SAST

```text
Source Code
   ↓
Semgrep
```

---

## Secret Scanning

```text
Repository
   ↓
Gitleaks / GitHub Secret Scanning
```

---

## Dependency Scanning

```text
Python Dependencies
   ↓
pip-audit
```

---

## Dependency Review

```text
Pull Request Dependency Changes
   ↓
Dependency Review
```

---

## Dockerfile Security

```text
Dockerfile
   ↓
Hadolint
```

---

## Container Security

```text
Docker Image
   ↓
Trivy
```

---

## SARIF

```text
Security Tool
   ↓
SARIF
   ↓
GitHub Security
```

---

## Least Privilege

```yaml
permissions:
  contents: read
```

Give additional permissions only when required.

---

## OIDC

```text
GitHub
 ↓
OIDC
 ↓
STS
 ↓
IAM Role
 ↓
Temporary AWS Credentials
```

---

## Secrets Manager

```text
Production Secrets
        ↓
AWS Secrets Manager
        ↓
Application Deployment
```

---

## SSM

```text
GitHub Actions
      ↓
AWS SSM
      ↓
EC2
```

---

## Image Promotion

```text
Build
 ↓
Save
 ↓
Artifact
 ↓
Load
 ↓
Scan
 ↓
Push
 ↓
Deploy
```

---

## Image Tag

```text
Full Git SHA
```

Avoid mutable:

```text
latest
```

for the application deployment artifact.

---

## Production

```text
Docker Hub
    ↓
EC2
    ↓
docker compose pull
    ↓
docker compose up
    ↓
/health
```

---

# Day 49 Security Tool Summary

| Security Area | Tool / Feature | Purpose |
|---|---|---|
| SAST | Semgrep | Analyze source code for security issues |
| Secret Scanning | Gitleaks | Detect exposed secrets |
| Secret Scanning | GitHub Secret Scanning | Detect leaked credentials in repository |
| Push Protection | GitHub | Prevent supported secrets from being pushed |
| Dependency Scan | pip-audit | Detect vulnerable Python dependencies |
| Dependency Review | GitHub Dependency Review | Review dependency changes in PRs |
| Dockerfile Lint | Hadolint | Detect Dockerfile issues and best-practice violations |
| Container Scan | Trivy | Scan image for known vulnerabilities |
| Security Reporting | SARIF | Send security findings to GitHub |
| Authentication | GitHub OIDC | Obtain short-lived AWS credentials |
| Cloud Authorization | IAM | Control AWS permissions |
| Remote Execution | AWS SSM | Execute deployment commands on EC2 |
| Secret Storage | AWS Secrets Manager | Store production secrets securely |

---

# Day 49 – What I Learned

The biggest lesson from Day 49 was that DevSecOps is not just:

```text
"Add Trivy."
```

It is a broader approach where security is integrated into the existing software delivery process.

I learned how different security controls protect different parts of the pipeline:

```text
Source Code
    ↓
Semgrep

Git Repository
    ↓
Gitleaks

Dependencies
    ↓
pip-audit / Dependency Review

Dockerfile
    ↓
Hadolint

Docker Image
    ↓
Trivy

GitHub Actions
    ↓
Least-Privilege Permissions + SHA Pinning

AWS Authentication
    ↓
OIDC + STS + IAM

Production Secrets
    ↓
AWS Secrets Manager
```

The most important architecture I learned was:

```text
Build Once
    ↓
Scan Same Image
    ↓
Push Same Image
    ↓
Deploy Same Image
```

This makes the CI/CD pipeline more traceable and reduces the possibility of deploying an artifact that was not the one that passed the security checks.

---

# Evolution of My Project

My project went through several stages during the DevOps learning journey.

## Stage 1 – Three-Tier Application

The initial project focused on:

```text
Application
    ↓
Database
```

and Dockerizing the application.

---

## Stage 2 – CI/CD

GitHub Actions was introduced.

The pipeline started handling:

```text
Build
 ↓
Test
 ↓
Docker Build
 ↓
Docker Push
 ↓
Deploy
```

---

## Stage 3 – Reusable Workflows

The pipeline was separated into reusable workflows.

```text
Main Pipeline
     ↓
Reusable Workflows
```

This improved maintainability.

---

## Stage 4 – Production Deployment

AWS EC2, Docker Compose, production environments, and deployment approval were added.

---

## Stage 5 – DevSecOps

Day 49 added security throughout the pipeline:

```text
SAST
Secret Scanning
Dependency Scanning
Dependency Review
Dockerfile Linting
Container Scanning
Least Privilege
Action Pinning
OIDC
Secrets Manager
```

The project therefore evolved from a basic CI/CD pipeline into a more complete DevSecOps workflow.

---

# Final Project Flow

```text
                         DEVELOPER
                             │
                             ↓
                      Pull Request
                             │
             ┌───────────────┴────────────────┐
             │                                │
             ↓                                ↓
          Lint/Test                       Security
                                             │
                    ┌────────────────────────┼───────────────────┐
                    ↓                        ↓                   ↓
                  SAST                  Secret Scan       Dependency Scan
                    │                        │                   │
                    └────────────────────────┼───────────────────┘
                                             ↓
                                      Dependency Review
                                             ↓
                                      Dockerfile Lint
                                             ↓
                                        PR Validation
                                             │
                                             ↓
                                          MERGE
                                             │
                                             ↓
                                       Push to main
                                             │
                                             ↓
                                      Build + Test
                                             │
                                             ↓
                                      Docker Build
                                             │
                                             ↓
                                  Save Exact Image Artifact
                                             │
                                             ↓
                                        Trivy Scan
                                             │
                                  ┌──────────┴──────────┐
                                  │                     │
                                FAIL                  PASS
                                  │                     │
                                  X                     ↓
                                                Docker Push
                                                      │
                                                      ↓
                                           Production Approval
                                                      │
                                                      ↓
                                                   OIDC
                                                      │
                                                      ↓
                                                    STS
                                                      │
                                                      ↓
                                                  IAM Role
                                                      │
                                                      ↓
                                                    SSM
                                                      │
                                                      ↓
                                                    EC2
                                                      │
                                                      ↓
                                             Secrets Manager
                                                      │
                                                      ↓
                                               Docker Compose
                                                      │
                                               ┌──────┴──────┐
                                               ↓             ↓
                                             Flask         MySQL
                                               │             │
                                               └──────┬──────┘
                                                      ↓
                                               Health Check
                                                      │
                                                      ↓
                                                PRODUCTION
```

---

# Day Completion Checklist

- [x] Understand what DevSecOps means
- [x] Add security checks to the CI/CD pipeline
- [x] Add SAST using Semgrep
- [x] Add secret scanning using Gitleaks
- [x] Understand GitHub Secret Scanning
- [x] Understand Push Protection
- [x] Add dependency vulnerability scanning using pip-audit
- [x] Add Dependency Review to the PR pipeline
- [x] Add Dockerfile linting using Hadolint
- [x] Add Docker image scanning using Trivy
- [x] Configure Trivy for HIGH and CRITICAL vulnerabilities
- [x] Configure Trivy to fail the pipeline when the security gate fails
- [x] Generate SARIF security reports
- [x] Upload SARIF results to GitHub Security
- [x] Add least-privilege GitHub Actions permissions
- [x] Pin important GitHub Actions to commit SHAs
- [x] Understand Build Once → Scan Same Image → Push Same Image
- [x] Use the full Git SHA as the application image tag
- [x] Understand GitHub OIDC
- [x] Understand AWS STS
- [x] Use GitHub OIDC for AWS authentication
- [x] Use AWS IAM for least-privilege authorization
- [x] Use AWS SSM for EC2 deployment
- [x] Use AWS Secrets Manager for production database secrets
- [x] Deploy the exact image that passed the security scan
- [x] Add a production health check
- [x] Understand production Docker Compose persistence
- [x] Understand the difference between application security tools
- [x] Complete the Day 49 DevSecOps implementation

---

# Final Takeaway

Day 49 changed the pipeline from simply being a CI/CD pipeline into a DevSecOps-oriented pipeline.

The important idea is:

```text
Security should not be a final step.
Security should be part of every stage of delivery.
```

My final project now performs security checks across:

```text
Code
 ↓
Dependencies
 ↓
Secrets
 ↓
Dockerfile
 ↓
Docker Image
 ↓
GitHub Actions Permissions
 ↓
AWS Authentication
 ↓
Production Secrets
 ↓
Production Deployment
```

The complete delivery model is:

```text
PR
 ↓
Validate
 ↓
Security Scan
 ↓
Merge
 ↓
Build
 ↓
Scan Exact Image
 ↓
Push Exact Image
 ↓
Production Approval
 ↓
OIDC → STS → IAM
 ↓
SSM → EC2
 ↓
Secrets Manager
 ↓
Docker Compose
 ↓
Health Check
 ↓
Production
```

The core DevSecOps lesson from this day is:

> **Build it, test it, secure it, and only then deploy it.**

That is the main concept I take away from Day 49.
