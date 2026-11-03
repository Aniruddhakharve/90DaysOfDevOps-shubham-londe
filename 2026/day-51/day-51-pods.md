# Day 51 – Kubernetes Manifests and Your First Pods

## Objective

Learn how to create and manage Kubernetes Pods using YAML manifests and imperative commands.

In this practical exercise, I worked with Nginx, BusyBox and Redis Pods and explored Pod configuration, logs, container access, YAML validation, labels and resource cleanup.

## Environment

- OS: Windows 11
- Terminal: VS Code Git Bash
- Container Runtime: Docker Desktop
- Kubernetes Cluster: KIND
- Cluster Name: devops-cluster
- Kubernetes Context: kind-devops-cluster
- Kubernetes Version: v1.37.0

---

## Task 1 – Create an Nginx Pod

### 1. Create the Pod manifest

Created `nginx-pod.yml` manually.

Location: `manifests/nginx-pod.yml`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

### 2. Apply the manifest

```bash
kubectl apply -f manifests/nginx-pod.yml
```

### 3. Verify the Pod

```bash
kubectl get pods
kubectl get pods -o wide
```

### 4. Describe the Pod

```bash
kubectl describe pod nginx-pod
```

This command displays detailed information about the Pod, including its configuration, labels, node assignment, conditions and events.

### 5. Check container logs

```bash
kubectl logs nginx-pod
```

### 6. Access the container

```bash
kubectl exec -it nginx-pod -- /bin/bash
```

Inside the container:

```bash
nginx -v
curl localhost:80
```

The curl command returned the default Nginx welcome page.

Exit the container:

```bash
exit
```

### Learning outcome

- Created a Pod using a YAML manifest.
- Inspected Pod details using `kubectl describe`.
- Viewed container logs.
- Accessed a running container using `kubectl exec`.
- Verified the Nginx web server using curl.

---

## Task 2 – Create a BusyBox Pod

### 1. Create the Pod manifest

Created `busybox-pod.yml` manually.

Location: `manifests/busybox-pod.yml`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev

spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

### 2. Apply the manifest

```bash
kubectl apply -f manifests/busybox-pod.yml
```

### 3. Check Pod status

```bash
kubectl get pods
```

### 4. Check logs

```bash
kubectl logs busybox-pod
```

Output:

```text
Hello from BusyBox
```

### 5. Inspect running processes

```bash
kubectl exec -it busybox-pod -- ps
```

Observed that `sleep 3600` was running as PID 1.

### Why use sleep 3600?

Containers remain running while their main process is running.

Without the sleep command, the echo command would finish and the container would exit.

The sleep command keeps the main process alive for 3600 seconds.

### Learning outcome

- Created a BusyBox Pod.
- Used a custom container command.
- Inspected container logs.
- Investigated the main process using `ps`.
- Understood why containers need a running main process.

---

## Task 3 – Imperative vs Declarative Approach

Kubernetes supports two common approaches to creating resources.

### 1. Imperative approach

In the imperative approach, we directly tell Kubernetes what action to perform using commands.

Example:

```bash
kubectl run redis-pod --image=redis:latest
```

Created a Redis Pod using the imperative command.

Verify:

```bash
kubectl get pods
```

Inspect the Pod configuration:

```bash
kubectl get pod redis-pod -o yaml
```

### 2. Declarative approach

In the declarative approach, we define the desired resource configuration in a YAML manifest and ask Kubernetes to apply it.

Example:

```bash
kubectl apply -f manifests/nginx-pod.yml
```

Kubernetes reads the manifest and works to make the actual cluster state match the desired configuration.

### Comparison

| Imperative | Declarative |
|---|---|
| Uses direct commands | Uses YAML manifest files |
| Tells Kubernetes what action to perform | Defines the desired state |
| Example: `kubectl run` | Example: `kubectl apply -f` |

### 3. Generate YAML using dry-run

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

Save the generated YAML:

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml > test-pod.yaml
```

Inspect the generated file:

```bash
cat test-pod.yaml
```

### Learning outcome

- Created a Redis Pod using an imperative command.
- Inspected the generated Kubernetes resource configuration.
- Generated YAML using `--dry-run=client`.
- Saved the generated YAML into a file.
- Understood the difference between imperative and declarative approaches.

---

## Task 4 – Validate Kubernetes YAML

Kubernetes provides dry-run options to validate resource configurations without actually creating or modifying resources.

### 1. Client-side dry-run

```bash
kubectl apply -f manifests/nginx-pod.yml --dry-run=client
```

Output:

```text
pod/nginx-pod unchanged (dry run)
```

Client-side dry-run performs local validation without sending the request to the Kubernetes API server.

### 2. Server-side dry-run

```bash
kubectl apply -f manifests/nginx-pod.yml --dry-run=server
```

Output:

```text
pod/nginx-pod unchanged (server dry run)
```

Server-side dry-run sends the request to the Kubernetes API server for validation without persisting the resource.

### 3. Test an invalid manifest

Temporarily removed the container image value:

```yaml
image:
```

Executed:

```bash
kubectl apply -f manifests/nginx-pod.yml --dry-run=server
```

Output:

```text
The Pod "nginx-pod" is invalid: spec.containers[0].image: Required value
```

The API server rejected the manifest because the required image field was empty.

### 4. Compare client and server validation

With the same invalid manifest, executed:

```bash
kubectl apply -f manifests/nginx-pod.yml --dry-run=client
```

Output:

```text
pod/nginx-pod configured (dry run)
```

Client-side dry-run accepted this particular invalid configuration, while server-side validation rejected it.

**Important:** A successful client-side dry-run does not guarantee that the Kubernetes API server will accept the manifest.

Restored the correct image:

```yaml
image: nginx:latest
```

### Learning outcome

- Practised client-side validation.
- Practised server-side validation.
- Observed how the API server rejects invalid resource configurations.
- Understood why server-side validation is important.

---

## Task 5 – Kubernetes Pod Labels

Labels are key-value pairs attached to Kubernetes resources.

They help organize, identify and select resources.

### 1. Display Pod labels

```bash
kubectl get pods --show-labels
```

Observed labels:

| Pod | Labels |
|---|---|
| nginx-pod | `app=nginx` |
| busybox-pod | `app=busybox`, `environment=dev` |
| redis-pod | `run=redis-pod` |

The Redis Pod received the `run=redis-pod` label automatically when created using `kubectl run`.

### 2. Filter Pods using labels

Filter by application:

```bash
kubectl get pods -l app=nginx
```

Filter by environment:

```bash
kubectl get pods -l environment=dev
```

A test with an incorrect label key:

```bash
kubectl get pods -l env=dev
```

Returned:

```text
No resources found in default namespace.
```

The correct label key was `environment`, not `env`.

### 3. Add a label

```bash
kubectl label pod nginx-pod environment=production
```

Verify:

```bash
kubectl get pods --show-labels
```

### 4. Remove a label

```bash
kubectl label pod nginx-pod environment-
```

Verify:

```bash
kubectl get pods --show-labels
```

The `-` at the end of the label key removes that label.

### 5. Create a third Pod with three labels

Created `third-pod.yml` manually.

Location: `manifests/third-pod.yml`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: third-pod
  labels:
    app: nginx
    environment: testing
    team: devops

spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f manifests/third-pod.yml
```

Verify:

```bash
kubectl get pods --show-labels
```

### 6. Practise label selectors

```bash
kubectl get pods -l app=nginx
kubectl get pods -l environment=testing
kubectl get pods -l team=devops
```

The `app=nginx` selector returned both `nginx-pod` and `third-pod` because both Pods shared that label.

### Learning outcome

- Displayed labels attached to Pods.
- Filtered Pods using label selectors.
- Added and removed labels.
- Created a Pod with three labels.
- Understood how labels help identify and group Kubernetes resources.

---

## Task 6 – Clean Up Resources

Deleted all Pods created during this exercise.

```bash
kubectl delete pod nginx-pod busybox-pod redis-pod third-pod
```

Output:

```text
pod "nginx-pod" deleted from default namespace
pod "busybox-pod" deleted from default namespace
pod "redis-pod" deleted from default namespace
pod "third-pod" deleted from default namespace
```

Verified:

```bash
kubectl get pods
```

Output:

```text
No resources found in default namespace.
```

### Important learning

These were standalone Pods.

When a standalone Pod is deleted, Kubernetes does not automatically recreate it.

Kubernetes Deployments provide a way to manage Pods and maintain the desired number of replicas.

We will explore Deployments in the next challenge.

---

## Day 51 – Key Commands Reference

| Command | Purpose |
|---|---|
| `kubectl apply -f file.yml` | Apply a manifest |
| `kubectl get pods` | List Pods |
| `kubectl get pods -o wide` | Display additional Pod information |
| `kubectl describe pod POD_NAME` | Display detailed Pod information |
| `kubectl logs POD_NAME` | View container logs |
| `kubectl exec -it POD_NAME -- /bin/bash` | Access a container shell |
| `kubectl run POD_NAME --image=IMAGE` | Create a Pod imperatively |
| `kubectl get pod POD_NAME -o yaml` | Display Pod configuration |
| `kubectl apply -f file.yml --dry-run=client` | Perform client-side dry-run |
| `kubectl apply -f file.yml --dry-run=server` | Perform server-side dry-run |
| `kubectl get pods --show-labels` | Display Pod labels |
| `kubectl get pods -l KEY=VALUE` | Filter Pods by label |
| `kubectl label pod POD_NAME KEY=VALUE` | Add a label |
| `kubectl label pod POD_NAME KEY-` | Remove a label |
| `kubectl delete pod POD_NAME` | Delete a Pod |

---

## Screenshots

All practical screenshots are available in the `screenshots/` directory.

| No. | Screenshot |
|---|---|
| 01 | Nginx Pod running |
| 02 | Nginx Pod description |
| 03 | Nginx Pod logs |
| 04 | Nginx container shell and curl |
| 05 | BusyBox Pod running |
| 06 | BusyBox logs |
| 07 | BusyBox process inspection |
| 08 | Redis Pod running |
| 09 | Redis Pod YAML |
| 10 | Generated YAML using dry-run |
| 11 | Client-side and server-side validation |
| 12 | Server-side validation error |
| 13 | Pod labels |
| 14 | Pod label selectors |
| 15 | Adding and removing labels |
| 16 | Third Pod with three labels |
| 17 | Pod cleanup |

---

## Day 51 – Final Summary

Completed the Kubernetes Pod and manifest exercises.

Key concepts learned:

- Kubernetes Pod manifests.
- Imperative and declarative resource management.
- Container logs and shell access.
- Client-side and server-side dry-run validation.
- YAML manifest generation.
- Kubernetes labels and selectors.
- Adding and removing labels.
- Standalone Pod lifecycle and cleanup.

**Status: Day 51 Completed**

Next: Day 52 – Kubernetes Deployments.