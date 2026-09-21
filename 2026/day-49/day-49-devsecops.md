# Day 49 – DevSecOps: Add Security to Your CI/CD Pipeline

## 📌 Overview

Day 49 focused on adding security checks to the CI/CD pipeline so that security problems can be detected automatically during the software delivery process.

For this task, I extended my existing CI/CD work into a complete **DevSecOps capstone project** using the intentionally vulnerable **OWASP NodeGoat** application.

Instead of adding only one security scan, I implemented multiple security layers covering:

- Source code security
- Secret detection
- Dependency vulnerabilities
- Dockerfile security
- Container image vulnerabilities
- Application health
- Dynamic application security testing

The final pipeline builds the application, performs security checks, publishes the Docker image to Docker Hub, deploys the exact image version to AWS EC2, verifies the application, and runs OWASP ZAP against the deployed application.

---

# 🎯 Day 49 Objectives

The trainer's Day 49 task focused on:

- Adding Docker image vulnerability scanning.
- Understanding secret scanning.
- Understanding dependency vulnerability scanning.
- Applying least-privilege workflow permissions.
- Integrating security into CI/CD.
- Documenting the resulting DevSecOps pipeline.

I implemented these concepts as part of a larger capstone pipeline so that security is integrated throughout the software delivery lifecycle.

---

# 🏗️ Project Used

I used:

```text
OWASP NodeGoat
```

NodeGoat is an intentionally vulnerable Node.js application designed for learning application security.

Project repository:

```text
https://github.com/Aniruddhakharve/devsecops-capstone-project
```

The repository contains the complete implementation, GitHub Actions workflows, Docker configuration, deployment configuration, and the resulting DevSecOps pipeline.

---

# 🔐 What is DevSecOps?

In my own words:

> DevSecOps means integrating security into the existing DevOps and CI/CD process instead of treating security as a separate activity at the end. Security checks can be automated so vulnerabilities, secrets, dependency issues, and insecure configurations are detected earlier in the software delivery lifecycle.

The basic idea is:

```text
Code
  ↓
Build
  ↓
Test
  ↓
Security Checks
  ↓
Package
  ↓
Deploy
  ↓
Test Running Application
```

Security becomes part of the pipeline instead of an afterthought.

---

# 🧰 Security Tools Used

| Security Area | Tool | Purpose |
|---|---|---|
| Code Quality | JSHint | JavaScript linting |
| SAST | Semgrep | Static application security testing |
| Secret Scanning | Gitleaks | Detect secrets in source/history |
| Dependency Scanning | npm audit | Detect vulnerable npm dependencies |
| Dockerfile Linting | Hadolint | Check Dockerfile practices |
| Image Scanning | Trivy | Detect container image vulnerabilities |
| DAST | OWASP ZAP | Test the running application |

---

# 🏗️ Final DevSecOps Architecture

```text
                           GitHub Repository
                                  │
                         Push / Pull Request
                                  │
                                  ▼
                       ┌────────────────────┐
                       │   Main Pipeline    │
                       │      main.yml      │
                       └──────────┬─────────┘
                                  │
                                Lint
                                  │
                  ┌───────────────┼────────────────┐
                  │               │                │
                  ▼               ▼                ▼
                Test             SAST         Secret Scan
                                  │
                  ┌───────────────┼────────────────┐
                  │               │                │
                  ▼               ▼                ▼
           Dependency Scan   Dockerfile Lint
                  │               │
                  └───────────────┼────────────────┘
                                  │
                                  ▼
                           Docker Build
                                  │
                                  ▼
                          Trivy Image Scan
                                  │
                                  ▼
                             Docker Hub
                                  │
                                  ▼
                              AWS EC2
                                  │
                           Docker Compose
                                  │
                       ┌──────────┴──────────┐
                       │                     │
                     NodeGoat             MongoDB
                       │
                       ▼
                 Health Check
                       │
                       ▼
                  OWASP ZAP
                     DAST
```

---

# 🔄 Final Pipeline Flow

The final dependency graph is:

```text
lint
 │
 ├──────────────┬──────────────┬──────────────┬──────────────────┐
 ▼              ▼              ▼              ▼                  ▼
test           SAST       secret-scan   dependency-scan   dockerfile-lint
 │              │              │              │                  │
 └──────────────┴──────────────┴──────────────┴──────────────────┘
                                      │
                                      ▼
                                docker-build
                                      │
                                      ▼
                                  image-scan
                                      │
                                      ▼
                                  docker-push
                                      │
                                      ▼
                                  deploy-ec2
                                      │
                                      ▼
                                  health-check
                                      │
                                      ▼
                                   zap-dast
```

The independent security jobs run in parallel after linting.

This improved the pipeline execution time compared with a fully sequential design.

One observed successful pipeline completed in approximately:

```text
6 minutes 29 seconds
```

---

# 🐳 Task 1 – Scan Docker Image for Vulnerabilities

## Tool Used

I used:

```text
Trivy
```

Trivy scans the Docker image for known vulnerabilities.

The implementation follows this flow:

```text
Docker Build
     ↓
Docker Save
     ↓
GitHub Actions Artifact
     ↓
Docker Load
     ↓
Trivy Scan
```

---

# 🏗️ Docker Build

The Docker image is created using:

```bash
docker build -t nodegoat:ci .
```

The image is then saved:

```bash
docker save nodegoat:ci -o nodegoat.tar
```

The resulting archive is uploaded as a GitHub Actions artifact.

---

# 📥 Loading the Image for Scanning

The image scanning workflow downloads the previously built artifact:

```yaml
- name: Download Docker image
  uses: actions/download-artifact@v4
  with:
    name: nodegoat-image
    run-id: ${{ inputs.build-run-id }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

The image is then loaded:

```bash
docker load -i nodegoat.tar
```

This avoids rebuilding the image during the scan.

---

# 🛡️ Trivy Configuration

The final Trivy step is:

```yaml
- name: Run Trivy image scan
  uses: aquasecurity/trivy-action@v0.36.0
  with:
    image-ref: nodegoat:ci
    format: table
    severity: CRITICAL,HIGH
    exit-code: 0
```

The scan focuses on:

```text
CRITICAL
HIGH
```

vulnerabilities.

---

# ⚠️ Why `exit-code: 0` Instead of `1`?

The trainer's example uses:

```yaml
exit-code: '1'
```

which makes the pipeline fail when CRITICAL or HIGH vulnerabilities are detected.

For this capstone, I intentionally used:

```yaml
exit-code: 0
```

because NodeGoat is an intentionally vulnerable application.

The security findings need to be detected and documented, but the purpose of this learning project is to allow the entire pipeline to demonstrate all stages.

Therefore the current behavior is:

```text
Vulnerability Found
        ↓
Trivy Reports Finding
        ↓
Report Uploaded
        ↓
Pipeline Continues
```

For a real production application, the policy could be changed to fail the pipeline when selected severity thresholds are exceeded.

---

# 📊 Trivy Findings

The image scan identified vulnerabilities in:

```text
Alpine Linux packages
```

and:

```text
Node.js application dependencies
```

Examples of packages with findings included:

```text
kind-of
body-parser
brace-expansion
marked
minimatch
```

The project intentionally retains vulnerable components because the application is being used for security learning.

A JSON report is also generated:

```bash
trivy image \
  --format json \
  --output trivy-report.json \
  --severity CRITICAL,HIGH \
  nodegoat:ci || true
```

The report is uploaded as a GitHub Actions artifact.

---

# 🔑 Task 2 – Secret Scanning

I used:

```text
Gitleaks
```

for secret scanning.

The workflow checks the repository with the full Git history:

```yaml
- name: checkout code
  uses: actions/checkout@v7
  with:
    fetch-depth: 0

- name: Run Gitleaks
  uses: gitleaks/gitleaks-action@v2
```

---

# 📚 Why `fetch-depth: 0`?

A shallow clone may not contain the complete Git history.

Using:

```yaml
fetch-depth: 0
```

allows the secret scanner to inspect previous commits as well as the current source tree.

This is important because a secret removed from the current version can still exist in an older commit.

---

# 🚨 Secret Detection During the Project

During development, Gitleaks detected secret-like content.

The findings included:

```text
Private key
Hardcoded ZAP API key
```

The configuration was changed so that the ZAP API key is read from the environment:

```javascript
process.env.ZAP_API_KEY || ""
```

The private key file was removed from the repository.

---

# 🧠 Important Secret Scanning Lesson

Removing a secret from the current source does not automatically remove it from Git history.

The general response to a real exposed credential should be:

```text
Detect
  ↓
Revoke / Rotate
  ↓
Remove from source
  ↓
Clean history when appropriate
```

Most importantly:

> Never hardcode credentials, passwords, API keys, tokens, or private keys into source code.

---

# 🔐 GitHub Secrets

The deployment pipeline uses GitHub Secrets for sensitive values such as:

```text
DOCKER_USERNAME
DOCKER_PASSWORD
EC2_HOST
EC2_USERNAME
EC2_SSH_KEY
```

These values are not hardcoded into the workflow files.

Reusable workflows receive repository secrets using:

```yaml
secrets: inherit
```

---

# 🔍 Secret Scanning vs Push Protection

## Secret Scanning

Secret scanning detects secret-like content that has entered repository content or history.

```text
Secret committed
      ↓
Secret Scanner
      ↓
Detection
```

## Push Protection

Push protection attempts to stop the secret from being pushed in the first place.

```text
Secret detected before push
      ↓
Push blocked
```

So the basic distinction is:

```text
Secret Scanning
    ↓
Detect exposed secret

Push Protection
    ↓
Prevent secret from being pushed
```

---

# 📦 Task 3 – Dependency Scanning

For dependency security, I used:

```text
npm audit
```

The workflow installs the dependencies:

```bash
npm ci
```

and generates a JSON vulnerability report:

```bash
npm audit --json > npm-audit-report.json || true
```

The report is uploaded as a GitHub Actions artifact.

---

# ⚠️ NodeGoat Dependency Vulnerabilities

The NodeGoat project uses an intentionally old dependency tree.

The initial dependency audit reported approximately:

```text
145 vulnerabilities

8 low
33 moderate
66 high
38 critical
```

A production application would require remediation.

However, I did not run:

```bash
npm audit fix --force
```

because the command can introduce breaking dependency changes and could break the intentionally old NodeGoat application.

Therefore this project uses dependency scanning primarily for:

```text
Detection
    ↓
Reporting
    ↓
Review
```

---

# 🧠 Dependency Review vs npm Audit

The trainer introduced:

```yaml
actions/dependency-review-action@v4
```

which is useful for checking dependency changes introduced by pull requests.

This project uses:

```text
npm audit
```

for auditing the NodeGoat dependency tree.

The difference can be summarized as:

```text
Dependency Review
        ↓
Review dependency changes in a PR

npm audit
        ↓
Audit project npm dependencies
```

---

# 🐳 Task 4 – Dockerfile Security

I used:

```text
Hadolint
```

for Dockerfile linting.

The workflow contains:

```yaml
- name: Run Hadolint
  uses: hadolint/hadolint-action@v3.3.0
  with:
    dockerfile: Dockerfile
```

This checks the Dockerfile for common problems and best-practice violations.

---

# 🔐 Docker Security Improvements

The final Dockerfile:

- Uses Node.js Alpine.
- Uses a multi-stage build.
- Installs production dependencies.
- Uses `.dockerignore`.
- Runs the application as a non-root user.
- Exposes only the required application port.

Final runtime user:

```dockerfile
USER $USER
```

where:

```text
USER=node
```

---

# 🧪 Task 5 – SAST

For Static Application Security Testing, I used:

```text
Semgrep
```

The workflow installs Semgrep:

```bash
python3 -m pip install semgrep
```

and runs:

```bash
semgrep scan \
  --config=auto \
  --json \
  --output=semgrep-report.json
```

The generated report is uploaded as an artifact.

---

# 📊 Semgrep Results

Because NodeGoat is intentionally vulnerable, Semgrep identified multiple security findings.

One observed scan produced approximately:

```text
WARNING: 25
ERROR:    7
INFO:     1
```

Examples included:

- Dangerous `eval()` usage.
- Private key material.
- Open redirect-related findings.
- Other insecure application coding patterns.

---

# 🔗 Security Layers in the Pipeline

The final security flow became:

```text
Source Code
     │
     ▼
JSHint
     │
     ▼
Semgrep
     │
     ▼
Gitleaks
     │
     ▼
npm audit
     │
     ▼
Hadolint
     │
     ▼
Docker Build
     │
     ▼
Trivy
     │
     ▼
Docker Hub
     │
     ▼
AWS EC2
     │
     ▼
OWASP ZAP
```

Security is therefore applied at multiple stages instead of being performed only after deployment.

---

# 🔀 Parallel Security Checks

The independent security stages were configured to run in parallel after linting.

For example:

```yaml
sast:
  needs: [lint]
```

```yaml
secret-scan:
  needs: [lint]
```

```yaml
dependency-scan:
  needs: [lint]
```

```yaml
dockerfile-lint:
  needs: [lint]
```

The jobs do not need to wait for one another.

This reduced the total pipeline execution time.

---

# ♻️ Reusable Workflows

The GitHub Actions pipeline is divided into separate reusable workflow files:

```text
main.yml
lint.yml
test.yml
sast.yml
secret-scan.yml
dependency-scan.yml
dockerfile-lint.yml
docker-build.yml
image-scan.yml
docker-push.yml
deploy-ec2.yml
health-check.yml
zap-dast.yml
```

Each reusable workflow uses:

```yaml
on:
  workflow_call:
```

The main workflow calls them.

Example:

```yaml
jobs:
  sast:
    needs: [lint]
    uses: ./.github/workflows/sast.yml
```

---

# 🧠 Important GitHub Actions Concepts Used

## `workflow_call`

Allows a workflow to be reused by another workflow.

```yaml
on:
  workflow_call:
```

---

## `needs`

Defines job dependencies.

```yaml
needs: docker-build
```

---

## `if`

Controls when a job should execute.

Deployment uses:

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/master'
```

This prevents pull requests from automatically deploying to EC2.

---

## `workflow_dispatch`

Allows the pipeline to be manually started.

---

## `inputs`

Inputs are used to pass values to reusable workflows.

Examples:

```text
build-run-id
image-tag
```

---

## `outputs`

The Docker build workflow exposes the generated image tag to later jobs.

---

## `id`

The Docker build step uses:

```yaml
id: meta
```

so its output can be referenced.

---

## `$GITHUB_OUTPUT`

The image tag is generated with:

```bash
echo "image-tag=${{ github.sha }}" >> "$GITHUB_OUTPUT"
```

---

## Artifacts

GitHub Actions artifacts are used to share:

```text
Docker image
Semgrep report
npm audit report
Trivy report
```

between jobs.

---

## Matrix

The lint workflow uses:

```yaml
strategy:
  matrix:
    node-version: [20, 22]
```

This checks the project with multiple Node.js versions.

---

# 🏷️ Docker Image Traceability

The Docker image tag is generated from:

```text
github.sha
```

The output is passed through the workflow chain:

```text
GitHub SHA
     ↓
Step Output
     ↓
Job Output
     ↓
Reusable Workflow Output
     ↓
Main Pipeline
     ↓
Docker Push
     ↓
EC2 Deployment
```

The image is published using both:

```text
<username>/nodegoat:<Git SHA>
```

and:

```text
<username>/nodegoat:latest
```

The SHA tag allows the deployment to use an exact image version.

---

# ☁️ AWS EC2 Deployment

After the image scan, the image is published to Docker Hub and deployed to AWS EC2.

The deployment workflow:

```text
Connect to EC2
      ↓
Check Docker
      ↓
Check Docker Compose
      ↓
Create ~/devops
      ↓
Copy docker-compose.yml
      ↓
Create .env
      ↓
Login to Docker Hub
      ↓
docker compose pull
      ↓
docker compose down
      ↓
docker compose up -d --force-recreate
```

The exact image tag generated from the Git commit is used during deployment.

---

# ❤️ Application Health Check

After deployment, the pipeline checks:

```text
http://<EC2_HOST>:4000/login
```

using:

```bash
curl -fsS http://${{ secrets.EC2_HOST }}:4000/login > /dev/null
```

The purpose is to verify that the application is actually reachable after deployment.

The successful output is:

```text
Checking application health...
Application is healthy.
```

---

# 🕷️ OWASP ZAP DAST

After the application health check succeeds, the pipeline runs:

```text
OWASP ZAP
```

against the running application.

The workflow uses:

```yaml
uses: zaproxy/action-baseline@v0.15.0
```

with:

```yaml
target: http://${{ secrets.EC2_HOST }}:4000
```

This is DAST because the scan interacts with the deployed and running application.

---

# 🧪 SAST vs DAST

## SAST

```text
Source Code
     ↓
Semgrep
     ↓
Security Findings
```

## DAST

```text
Running Application
        ↓
       ZAP
        ↓
Security Findings
```

Therefore:

```text
SAST → Code
DAST → Running Application
```

---

# 🐢 Why Use ZAP Baseline?

I initially tested the full ZAP scan.

The full scan took approximately:

```text
42+ minutes
```

which was too slow for the regular CI/CD pipeline.

I therefore switched to:

```yaml
zaproxy/action-baseline@v0.15.0
```

The baseline scan completed in approximately:

```text
7 minutes
```

as part of the pipeline.

---

# 🔎 ZAP Findings

The DAST scan identified web security observations including:

- Missing security headers.
- Directory browsing.
- Vulnerable JavaScript libraries.
- Cross-domain JavaScript concerns.
- XSS-related findings.
- Other web security observations.

The scan successfully completed as part of the final pipeline.

---

# 🔐 Least Privilege

A key DevSecOps principle is:

> Give a workflow only the permissions it actually needs.

For workflows that only need repository read access, the principle can be represented as:

```yaml
permissions:
  contents: read
```

This reduces the potential impact if a third-party action or workflow component is compromised.

The important idea is:

```text
Minimum required permissions
            ↓
Smaller attack surface
```

---

# 🔄 Pull Request vs Push Behavior

The main pipeline supports:

```yaml
push:
  branches:
    - master

pull_request:
  branches:
    - master

workflow_dispatch:
```

For pull requests, validation and security checks run.

The production deployment condition is:

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/master'
```

Therefore:

```text
Pull Request
    ↓
CI + Security Checks
    ↓
No EC2 deployment
```

while:

```text
Push to master
    ↓
CI + Security Checks
    ↓
Docker Hub
    ↓
EC2 Deployment
    ↓
Health Check
    ↓
ZAP DAST
```

---

# 🔐 Security Policy for This Capstone

Because NodeGoat is intentionally vulnerable, several security checks are configured as report-only.

Current behavior:

```text
Semgrep
   ↓
Report findings

Gitleaks
   ↓
Detect secrets

npm audit
   ↓
Report dependency vulnerabilities

Trivy
   ↓
Report image vulnerabilities

ZAP
   ↓
Report web security findings
```

This does not mean these vulnerabilities would be acceptable in production.

In a production environment, security policy could be configured to block releases based on defined severity thresholds.

---

# 🧠 DevSecOps Principle Demonstrated

Instead of:

```text
Build
 ↓
Deploy
 ↓
Security
```

the capstone uses:

```text
Code
 ↓
SAST
 ↓
Secret Scan
 ↓
Dependency Scan
 ↓
Dockerfile Scan
 ↓
Docker Build
 ↓
Image Scan
 ↓
Deploy
 ↓
Health Check
 ↓
DAST
```

Security is integrated throughout the delivery lifecycle.

---

# 📊 Complete Pipeline Summary

| Stage | Tool | Purpose |
|---|---|---|
| Lint | JSHint | Code quality |
| Test | npm test | Verify application test command |
| SAST | Semgrep | Static security analysis |
| Secret Scan | Gitleaks | Detect secrets |
| Dependency Scan | npm audit | Dependency vulnerabilities |
| Dockerfile Lint | Hadolint | Dockerfile security/practices |
| Build | Docker | Create container image |
| Image Scan | Trivy | Container vulnerabilities |
| Push | Docker Hub | Store image |
| Deploy | SSH + Docker Compose | Deploy to EC2 |
| Health Check | curl | Verify application |
| DAST | OWASP ZAP | Test running application |

---

# 📚 What I Learned

## 1. Security should be part of CI/CD

Security checks should be automated rather than relying only on manual reviews.

## 2. Vulnerabilities can exist at multiple layers

```text
Application Code
       ↓
Dependencies
       ↓
Dockerfile
       ↓
Base Image
       ↓
Container
       ↓
Running Application
```

## 3. SAST and DAST serve different purposes

```text
SAST → Analyze source code
DAST → Test running application
```

## 4. Container images can contain vulnerabilities

A working application can still contain vulnerable OS packages or dependencies.

## 5. Secrets should never be hardcoded

Credentials should be stored using appropriate secret-management mechanisms.

## 6. Git history matters

A secret removed from the current source can still exist in previous commits.

## 7. Security policy and security scanning are different

A scanner detects the vulnerability.

The pipeline policy determines whether that vulnerability:

```text
Blocks deployment
```

or:

```text
Generates a report
```

---

# 🧪 Verification

The final DevSecOps pipeline successfully completed:

```text
✅ Lint
✅ Test
✅ SAST
✅ Secret Scan
✅ Dependency Scan
✅ Dockerfile Lint
✅ Docker Build
✅ Trivy Image Scan
✅ Docker Hub Push
✅ EC2 Deployment
✅ Application Health Check
✅ OWASP ZAP DAST
```

The pipeline also successfully executed after the final project README update.

---

# 🔗 Project Repository

The complete implementation can be reviewed here:

```text
https://github.com/Aniruddhakharve/devsecops-capstone-project
```

The repository contains the complete source code, Docker configuration, Compose configuration, GitHub Actions workflows, security scanning configuration, deployment configuration, and project documentation.

---

# 🎤 How I Would Explain Day 49 in an Interview

> "For Day 49, I extended my CI/CD pipeline into a DevSecOps pipeline using the OWASP NodeGoat application. I added Semgrep for SAST, Gitleaks for secret scanning, npm audit for dependency vulnerabilities, Hadolint for Dockerfile linting, Trivy for Docker image scanning, and OWASP ZAP for DAST.
>
> I split the pipeline into reusable GitHub Actions workflows using workflow_call. The independent security checks run in parallel after linting, which reduced the overall pipeline execution time.
>
> The Docker image is built once, saved as a GitHub Actions artifact, scanned with Trivy, and then pushed to Docker Hub using a Git SHA tag. I pass the SHA using GitHub Actions step outputs, job outputs, workflow inputs, and reusable workflow outputs.
>
> The exact image version is then deployed to AWS EC2 using SSH and Docker Compose. After deployment, the pipeline performs an HTTP health check and finally runs OWASP ZAP baseline DAST against the live application.
>
> Since NodeGoat is intentionally vulnerable, the security scans are primarily configured for reporting in this learning project. In a production environment, critical findings could be configured to fail the pipeline and block deployment."

---

# ❓ Interview Questions and Answers

## What is DevSecOps?

DevSecOps means integrating security practices and automated security checks into the DevOps lifecycle instead of treating security as a separate process at the end.

---

## Why did you use Trivy?

I used Trivy to scan the Docker image for known vulnerabilities in the container's OS packages and application dependencies.

---

## What is a CVE?

CVE stands for:

```text
Common Vulnerabilities and Exposures
```

It provides a standardized identifier for publicly known security vulnerabilities.

---

## What is SAST?

SAST stands for:

```text
Static Application Security Testing
```

It analyzes source code without requiring the application to run.

I used Semgrep.

---

## What is DAST?

DAST stands for:

```text
Dynamic Application Security Testing
```

It tests the running application from the outside.

I used OWASP ZAP.

---

## Why did you use both SAST and DAST?

They test different layers:

```text
SAST → Source code
DAST → Running application
```

Using both provides broader security coverage.

---

## Why did you use Gitleaks?

Gitleaks detects credentials and secret-like values in source code and Git history.

---

## Why use `fetch-depth: 0`?

It makes the complete Git history available so Gitleaks can inspect older commits as well as the current source.

---

## Why use npm audit?

It checks npm dependencies against known vulnerability information.

---

## Why use Hadolint?

Hadolint checks the Dockerfile for common mistakes and recommended Docker practices.

---

## Why did you use report-only scanning?

NodeGoat is intentionally vulnerable.

The purpose of the capstone is to demonstrate how DevSecOps tools detect vulnerabilities.

A production pipeline could enforce stricter gates.

---

## Why did you use Git SHA as the Docker image tag?

A Git SHA uniquely identifies the source commit used to create the image.

This gives traceability:

```text
Git Commit
    ↓
Docker Image
    ↓
Docker Hub
    ↓
EC2 Deployment
```

---

## Why save the Docker image as an artifact?

The image is built once and reused by later jobs.

Therefore the image scanned by Trivy is the same built image that is pushed to Docker Hub.

---

## Why use reusable workflows?

Reusable workflows separate the pipeline into logical stages and avoid putting every operation into one large workflow.

---

## Why use `needs`?

`needs` creates dependencies between jobs.

For example:

```yaml
image-scan:
  needs: docker-build
```

means the image scan starts only after Docker build completes.

---

## Why parallelize the security checks?

The security checks are largely independent after linting, so running them concurrently reduces total pipeline execution time.

---

# 🧠 Quick Revision Cheat Sheet

## Security Tools

```text
JSHint
 ↓
Code Quality

Semgrep
 ↓
SAST

Gitleaks
 ↓
Secrets

npm audit
 ↓
Dependencies

Hadolint
 ↓
Dockerfile

Trivy
 ↓
Container Image

OWASP ZAP
 ↓
DAST
```

---

## GitHub Actions

```text
workflow_call
    ↓
Reusable Workflow

needs
    ↓
Job Dependency

if
    ↓
Conditional Execution

workflow_dispatch
    ↓
Manual Execution

inputs
    ↓
Pass Values Into Workflow

outputs
    ↓
Pass Values Out

id
    ↓
Identify Step

GITHUB_OUTPUT
    ↓
Create Step Output

artifacts
    ↓
Share Files Between Jobs

secrets
    ↓
Protect Sensitive Data

matrix
    ↓
Multiple Configurations
```

---

## Docker

```text
Dockerfile
     ↓
Image
     ↓
Container
     ↓
Network
     ↓
Compose
     ↓
Volume
     ↓
Healthcheck
```

---

# 🏁 Final Takeaway

The main lesson from Day 49 was:

> Security should be integrated into the software delivery lifecycle rather than being treated as a final manual step.

The project now follows:

```text
Source Code
     ↓
Lint
     ↓
Test
     ↓
SAST
     ↓
Secret Scan
     ↓
Dependency Scan
     ↓
Dockerfile Lint
     ↓
Docker Build
     ↓
Trivy Image Scan
     ↓
Docker Hub
     ↓
AWS EC2
     ↓
Health Check
     ↓
OWASP ZAP DAST
```

This Day 49 implementation combines the CI/CD concepts from the previous work with practical DevSecOps security controls.

The complete project can be viewed here:

```text
https://github.com/Aniruddhakharve/devsecops-capstone-project
```

# 🚀 Day 49 Complete
