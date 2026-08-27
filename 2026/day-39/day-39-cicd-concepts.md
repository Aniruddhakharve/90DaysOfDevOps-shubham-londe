# Day 39 – What is CI/CD?

## 📌 Overview

Day 39 focused on understanding the **concepts behind CI/CD** before writing an actual pipeline.

The goal was to understand why CI/CD exists, the difference between Continuous Integration, Continuous Delivery, and Continuous Deployment, and the main components of a CI/CD pipeline.

No pipeline was implemented today. This was a **concept and research day**.

---

# 🎯 Why Do We Need CI/CD?

Imagine a team of five developers working on the same application and manually deploying their changes to production.

Without automation, the process could look like:

```text
Developer
    ↓
Write Code
    ↓
Push Code
    ↓
Manually Build
    ↓
Manually Test
    ↓
Manually Deploy
    ↓
Production
```

This can create many problems.

### Common Problems

- Integration conflicts between developers
- Human errors during deployment
- Missing or inconsistent testing
- Slow feedback when something breaks
- Difficult rollback procedures
- Different environments between developers and production
- Manual deployment becoming repetitive and unreliable

---

# 💻 "It Works on My Machine"

One common software development problem is:

> "It works on my machine."

This happens when an application works correctly in one environment but fails in another.

For example:

```text
Developer Machine
-----------------
Java 17
Maven X
Dependency X
Ubuntu X

        ↓

Production Server
-----------------
Java 11
Maven Y
Dependency Y
Different OS
```

The application may behave differently because the environments are different.

This is one of the problems containerization helps address.

Docker can package an application together with the runtime environment it needs, making the application environment more consistent.

---

# 🔵 Continuous Integration (CI)

**Continuous Integration** is the practice of frequently integrating code changes into a shared repository and automatically building and testing those changes.

A simplified CI workflow:

```text
Developer
    ↓
git push
    ↓
CI Pipeline
    ↓
Build
    ↓
Tests
    ↓
Feedback
```

CI helps detect problems early, such as:

- Build failures
- Compilation errors
- Failed automated tests
- Dependency problems
- Integration problems

### Example

A developer pushes code:

```bash
git push origin main
```

The CI system automatically:

```text
Checkout Code
     ↓
Install Dependencies
     ↓
Build Application
     ↓
Run Tests
     ↓
Report Result
```

If something fails, the developer receives feedback quickly.

---

# 🟢 Continuous Delivery

**Continuous Delivery** goes beyond CI.

The application is automatically built, tested, packaged, and prepared so that it is ready to be released.

A simplified workflow:

```text
Push Code
    ↓
Build
    ↓
Test
    ↓
Package
    ↓
Deploy to Staging
    ↓
Ready for Production
    ↓
Manual Approval
    ↓
Production
```

The important difference is that the software is kept in a **release-ready state**, but production deployment can still require a manual approval.

### Example

```text
Developer Push
      ↓
CI
      ↓
Build + Test
      ↓
Docker Image
      ↓
Staging
      ↓
Manual Approval
      ↓
Production
```

---

# 🔴 Continuous Deployment

**Continuous Deployment** takes automation one step further.

After the required checks successfully pass, the application is automatically deployed to production.

```text
Developer Push
      ↓
Build
      ↓
Test
      ↓
Security Checks
      ↓
Package
      ↓
Production
```

There is normally no manual production approval in the successful path.

### Example

```text
git push
   ↓
Automated Tests
   ↓
Build Docker Image
   ↓
Security Scan
   ↓
Deploy
   ↓
Production
```

---

# ⚡ CI vs Continuous Delivery vs Continuous Deployment

| Concept | Main Idea | Production Deployment |
|---|---|---|
| **Continuous Integration** | Frequently build and test integrated code | Not necessarily |
| **Continuous Delivery** | Keep software ready to release | Usually requires approval |
| **Continuous Deployment** | Automatically release validated changes | Automatic |

### Easy Way to Remember

```text
CI
↓
Build + Test

Continuous Delivery
↓
Build + Test + Release Ready

Continuous Deployment
↓
Build + Test + Automatically Deploy
```

---

# 🔧 CI/CD Pipeline Anatomy

A CI/CD pipeline consists of several important components.

---

## 1. Trigger

A **trigger** determines what starts the pipeline.

Common triggers include:

```text
git push
Pull Request
Manual Trigger
Scheduled Event
Tag Creation
```

For example:

```yaml
on:
  push:
    branches:
      - main
```

This means the workflow starts when code is pushed to the `main` branch.

---

## 2. Stage

A **stage** is a logical phase of the pipeline.

Common stages include:

```text
Build
Test
Security Scan
Deploy
```

Conceptually:

```text
Build Stage
     ↓
Test Stage
     ↓
Deploy Stage
```

---

## 3. Job

A **job** is a unit of work executed by a runner.

For example:

```text
Test Stage
    ├── Unit Tests
    └── Integration Tests
```

These could be implemented as separate jobs.

In GitHub Actions, jobs are defined under:

```yaml
jobs:
```

Example:

```yaml
jobs:
  test:
    ...
```

---

## 4. Step

A **step** is an individual command or action inside a job.

Example:

```yaml
steps:
  - uses: actions/checkout@v4

  - run: mvn test

  - run: docker build -t myapp .
```

The relationship is:

```text
Pipeline
   ↓
Job
   ↓
Steps
```

---

## 5. Runner

A **runner** is the machine or environment where the job actually executes.

For example:

```text
GitHub Actions
      ↓
Ubuntu Runner
      ↓
Job Executes
      ↓
Commands Run
```

A runner can be:

- GitHub-hosted
- Self-hosted

I have already worked with a **self-hosted GitHub Actions runner**, so this concept connects with the Docker and GitHub Actions work completed previously.

---

## 6. Artifact

An **artifact** is an output produced by a job that can be stored or used by later stages/jobs.

Examples include:

```text
app.war
app.jar
Test Reports
Build Files
Logs
Packages
```

For example:

```text
Source Code
    ↓
Maven Build
    ↓
app.war
    ↓
Artifact
    ↓
Deployment
```

This is similar to the `app.war` generated during the three-tier Java application project.

---

# 🔄 Complete Pipeline Flow

Putting the concepts together:

```text
                    TRIGGER
                       │
                    git push
                       │
                       ▼
                 ┌───────────┐
                 │   BUILD   │
                 └─────┬─────┘
                       │
                      Job
                       │
                  ┌────┴────┐
                  │         │
               Step 1    Step 2
              Checkout    Build
                  │
                  ▼
               Artifact
                app.war
                  │
                  ▼
                 TEST
                  │
                  ▼
                DEPLOY
                  │
                  ▼
               STAGING
```

The actual commands are executed by a **runner**.

---

# 📊 Pipeline Diagram

For the required scenario:

> A developer pushes code to GitHub. The application is tested, built into a Docker image, and deployed to a staging server.

The pipeline can be represented as:

```text
┌──────────────────────┐
│      Developer       │
│                      │
│      git push        │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│       GitHub         │
│                      │
│      Trigger         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│     STAGE 1          │
│       TEST           │
│                      │
│  Run automated tests │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│     STAGE 2          │
│       BUILD          │
│                      │
│  Build Docker Image  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│     STAGE 3          │
│      DEPLOY          │
│                      │
│   Staging Server     │
└──────────────────────┘
```

### More Detailed View

```text
Developer
    │
    │ git push
    ▼
┌─────────────────┐
│     GitHub      │
└────────┬────────┘
         │
         │ Trigger
         ▼
┌─────────────────┐
│ GitHub Actions  │
│     Runner      │
└────────┬────────┘
         │
         ▼
   ┌────────────┐
   │    TEST    │
   │            │
   │ Unit Tests │
   └─────┬──────┘
         │
         ▼
   ┌────────────┐
   │   BUILD    │
   │            │
   │ Docker     │
   │ Image      │
   └─────┬──────┘
         │
         ▼
   ┌────────────┐
   │   DEPLOY   │
   │            │
   │  Staging   │
   │   Server   │
   └────────────┘
```

---

# 🌎 Exploring CI/CD in the Real World

As part of this task, an open-source GitHub repository can be inspected to understand how real projects implement CI/CD.

The important location to look for is:

```text
.github/
└── workflows/
```

Inside this directory, workflow YAML files define automated processes.

When inspecting a workflow, look for:

```yaml
on:
```

to identify the trigger.

Look for:

```yaml
jobs:
```

to identify the jobs.

Then inspect:

```yaml
runs-on:
steps:
uses:
run:
```

to understand what the workflow actually does.

---

# 🧩 CI/CD Is a Practice, Not a Tool

CI/CD is **not a single software product**.

It is a collection of software development, testing, integration, and delivery practices.

Tools can be used to implement these practices.

Examples:

```text
CI/CD Practices
       │
       ├── GitHub Actions
       ├── Jenkins
       ├── GitLab CI/CD
       └── CircleCI
```

The tool may change, but the underlying CI/CD concepts remain similar.

---

# ❌ A Failed Pipeline Is Not Necessarily Bad

Consider this:

```text
Developer Push
      ↓
CI Pipeline
      ↓
Build
      ↓
Tests
      ↓
❌ Test Failed
```

The pipeline has detected a problem before the change could continue further.

Therefore:

> **A failing pipeline can be a successful safety mechanism.**

The goal is not to make pipelines never fail.

The goal is to make failures:

- Fast to detect
- Easy to understand
- Easy to fix

---

# 🔗 Connection With Previous Days

The previous Docker and YAML learning now connects directly with CI/CD.

```text
Git
 │
 │ git push
 ▼
GitHub
 │
 ▼
CI/CD Pipeline
 │
 ├── Build
 │
 ├── Test
 │
 ├── Docker Build
 │
 ▼
Docker Image
 │
 ▼
Container
 │
 ▼
Application
```

YAML from Day 38 also becomes important:

```text
YAML
 ↓
Pipeline Configuration
 ↓
GitHub Actions
 ↓
CI/CD
```

Docker knowledge from Days 29–37 also fits into the pipeline:

```text
CI Pipeline
     ↓
docker build
     ↓
Docker Image
     ↓
docker push
     ↓
Container Registry
     ↓
Deployment
```

---

# 🧠 Key Takeaways

## 1. CI Provides Fast Feedback

Continuous Integration automatically builds and tests frequently integrated code so problems can be discovered early.

## 2. Delivery and Deployment Are Different

Continuous Delivery keeps software ready for production release, while Continuous Deployment automatically releases successful changes to production.

## 3. Pipelines Have Multiple Components

A pipeline can be understood using:

```text
Trigger
   ↓
Stage
   ↓
Job
   ↓
Step
   ↓
Runner
   ↓
Artifact
```

Each component has a different responsibility.

---

# 📝 Day 39 Self-Assessment

| Topic | Status |
|---|---|
| Why CI/CD exists | ✅ Can explain |
| "It works on my machine" | ✅ Can explain |
| Continuous Integration | ✅ Can explain |
| Continuous Delivery | ✅ Can explain |
| Continuous Deployment | ✅ Can explain |
| Delivery vs Deployment | ✅ Can explain |
| Pipeline Trigger | ✅ Can explain |
| Stage | ✅ Can explain |
| Job | ✅ Can explain |
| Step | ✅ Can explain |
| Runner | ✅ Can explain |
| Artifact | ✅ Can explain |
| Pipeline failure | ✅ Can explain |
| Docker in CI/CD | ✅ Can explain |
| YAML in CI/CD | ✅ Can explain |

---

# 📁 Expected Day 39 Structure

```text
day-39/
└── day-39-cicd-concepts.md
```

---

# 🚀 What I Learned Today

Day 39 gave me the conceptual foundation required before implementing CI/CD pipelines.

I learned that CI/CD helps automate the process of integrating, testing, packaging, and delivering software.

I also learned the difference between:

```text
Continuous Integration
        ↓
Continuous Delivery
        ↓
Continuous Deployment
```

I now understand the basic anatomy of a pipeline:

```text
Trigger → Stage → Job → Step → Runner → Artifact
```

Most importantly, I understand how my previous Docker and YAML knowledge will fit into the upcoming CI/CD implementation.

---

# 🏁 Day 39 Completed

**Day 39 – What is CI/CD?** ✅

Today I focused on understanding the **why and how of CI/CD** before writing pipelines.

The next step is to start working with an actual CI/CD tool and convert these concepts into a real pipeline.

---

**#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #CICD #DevOps #GitHubActions #Docker #YAML**
