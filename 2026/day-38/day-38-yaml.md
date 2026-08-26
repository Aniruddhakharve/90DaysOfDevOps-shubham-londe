# Day 38 – YAML Basics

## 📌 Overview

Day 38 focused on learning the fundamentals of **YAML (YAML Ain't Markup Language)**, which is widely used across DevOps tools and platforms.

Before working with CI/CD pipelines, Docker Compose, Kubernetes manifests, Ansible playbooks, and GitHub Actions workflows, understanding YAML syntax and indentation is essential.

---

## 🎯 Goal

The goal of Day 38 was to:

- Understand YAML syntax and structure
- Work with key-value pairs
- Create lists
- Create nested objects
- Work with multi-line strings
- Understand YAML indentation
- Understand the difference between `|` and `>`
- Validate YAML files using `yamllint`
- Identify common YAML syntax and indentation errors

---

# 🧠 What I Learned

## 1. Key-Value Pairs

The basic structure of YAML is a key followed by a value:

```yaml
name: Aniruddha
role: DevOps Learner
experience_years: 0
learning: true
```

YAML does not require quotes around normal strings.

Boolean values can be written as:

```yaml
learning: true
```

While:

```yaml
learning: "true"
```

represents a string rather than a boolean.

---

# 2. YAML Lists

YAML supports lists in two common formats.

### Block Style

```yaml
tools:
  - Docker
  - Kubernetes
  - Terraform
  - Ansible
  - Git
```

Each item starts with `-`.

### Inline Style

```yaml
hobbies: [Gaming, Learning, Styling]
```

Both represent a list, but the block style is generally easier to read when the list contains many items.

---

# 3. Nested Objects

YAML uses indentation to represent hierarchy.

Example:

```yaml
server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

database:
  host: localhost
  name: appdb
  credentials:
    user: appuser
    password: appsecret
```

Here:

```text
server
├── name
├── ip
└── port

database
├── host
├── name
└── credentials
    ├── user
    └── password
```

The indentation tells YAML which keys belong to which parent.

---

# ⚠️ YAML Indentation

One of the most important YAML rules is:

> **Use spaces for indentation. Never use tabs.**

Example:

```yaml
server:
  name: web-server
  port: 8080
```

The two spaces before `name` and `port` indicate that they belong to `server`.

Incorrect indentation can cause YAML parsing or validation errors.

For this reason, maintaining consistent indentation is extremely important when working with YAML-based DevOps tools.

---

# 4. Multi-line Strings

YAML provides two useful operators for multi-line strings.

## `|` Block Style

The `|` operator preserves newlines.

Example:

```yaml
startup_script: |
  #!/bin/bash
  echo "Starting application"
  systemctl start nginx
  echo "Application started"
```

The resulting value keeps the line breaks.

This is useful when the content needs to maintain its original formatting, such as:

- Shell scripts
- Configuration files
- Certificates
- Multi-line text

---

## `>` Fold Style

The `>` operator folds multiple lines into a single line.

Example:

```yaml
description: >
  This is a multi-line description
  that will be folded into
  a single line.
```

This is useful when the content is logically one continuous line but is written across multiple lines for readability.

### Quick Difference

```text
|  → Preserve newlines
>  → Fold newlines into spaces
```

---

# 5. YAML Validation with yamllint

I used `yamllint` to validate the YAML files.

Commands used:

```bash
yamllint person.yaml
```

```bash
yamllint server.yaml
```

Both files passed validation successfully without any reported errors.

A successful validation with no output means `yamllint` did not find any problems according to its configured rules.

---

# 🧪 Files Created

During Day 38, I created:

```text
day-38/
├── person.yaml
├── server.yaml
└── day-38-yaml.md
```

---

# 📄 person.yaml

The `person.yaml` file was created to practice:

- Key-value pairs
- Boolean values
- Lists
- Inline lists

Example structure:

```yaml
name: Aniruddha
role: DevOps Learner
experience_years: 0
learning: true

tools:
  - Docker
  - Kubernetes
  - Terraform
  - Ansible
  - Git

hobbies: [Gaming, Learning, Styling]
```

---

# 📄 server.yaml

The `server.yaml` file was created to practice:

- Nested objects
- Multiple levels of indentation
- Database configuration
- Nested credentials
- Multi-line strings

Example structure:

```yaml
server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

database:
  host: localhost
  name: appdb
  credentials:
    user: appuser
    password: appsecret

startup_script: |
  #!/bin/bash
  echo "Starting application"
```

---

# 🔍 Validation Performed

### Validate `person.yaml`

```bash
yamllint person.yaml
```

Result:

```text
No errors reported
```

### Validate `server.yaml`

```bash
yamllint server.yaml
```

Result:

```text
No errors reported
```

---

# 🧩 YAML Syntax Example

A complete example combining the concepts learned:

```yaml
application:
  name: three-tier-java-app
  version: "1.0"

server:
  host: localhost
  port: 8080

database:
  host: postgres
  port: 5432
  name: appdb
  credentials:
    user: appuser
    password: appsecret

tools:
  - Docker
  - Kubernetes
  - Terraform
  - Ansible
  - Git

hobbies: [Gaming, Learning, Styling]

startup_script: |
  #!/bin/bash
  echo "Starting application"
  echo "Checking services"
```

---

# ❓ Spot the Difference

### Correct YAML

```yaml
name: devops
tools:
  - docker
  - kubernetes
```

### Broken YAML

```yaml
name: devops
tools:
- docker
  - kubernetes
```

The second example has inconsistent indentation for the list items.

Correct:

```yaml
tools:
  - docker
  - kubernetes
```

---

# 🛠️ Common YAML Rules

| Rule | Example |
|---|---|
| Key-value pair | `name: devops` |
| List | `- docker` |
| Nested value | Indent with spaces |
| Boolean | `enabled: true` |
| String | `name: docker` |
| Inline list | `tools: [docker, git]` |
| Preserve newlines | `|` |
| Fold newlines | `>` |
| Indentation | Use spaces |
| Tabs | ❌ Avoid |

---

# 🔥 Key Takeaways

### 1. Indentation Defines Structure

Unlike many programming languages, YAML relies heavily on indentation.

```yaml
server:
  name: web
  port: 8080
```

The indentation establishes the relationship between `server` and its child keys.

### 2. YAML Uses Spaces, Not Tabs

Always use spaces for indentation.

```yaml
server:
  name: web
```

Avoid tabs because they can cause YAML parsing or validation errors.

### 3. YAML Is Everywhere in DevOps

The concepts learned today will be directly useful when working with:

```text
Docker Compose
      ↓
GitHub Actions
      ↓
Kubernetes
      ↓
Ansible
      ↓
Helm
      ↓
CI/CD Pipelines
```

Understanding YAML now provides the foundation for working with these tools.

---

# 🧠 Day 38 Self-Check

| Topic | Status |
|---|---|
| Key-value pairs | ✅ Can do |
| Lists | ✅ Can do |
| Nested objects | ✅ Can do |
| YAML indentation | ✅ Can do |
| Multi-line strings | ✅ Can do |
| `|` vs `>` | ✅ Can do |
| YAML validation | ✅ Can do |
| `yamllint` | ✅ Can do |
| YAML syntax errors | ✅ Can identify |

---

# 🚀 What Comes Next?

YAML is now ready to be used in actual DevOps workflows.

The next stages will build upon these fundamentals and use YAML for automation and CI/CD.

---

## 📚 Commands Used

```bash
# Display YAML file
cat person.yaml

# Validate YAML
yamllint person.yaml

# Validate another YAML file
yamllint server.yaml
```

---

# 🏁 Day 38 Completed

**Day 38 – YAML Basics** ✅

Today I learned the fundamentals of YAML, practiced creating structured configuration files, worked with lists and nested objects, learned multi-line string syntax, and validated my YAML files using `yamllint`.

> **YAML looks simple, but indentation defines everything.**

---

**#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #YAML #DevOps #Docker #CI/CD**
