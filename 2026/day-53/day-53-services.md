# Day 53 - Kubernetes Services

## Overview

On Day 53 of the 90 Days of DevOps challenge, I explored Kubernetes Services and learned how to expose applications running inside a Kubernetes cluster.

I deployed a three-replica Nginx application and exposed it using three different Kubernetes Service types:

- ClusterIP
- NodePort
- LoadBalancer

I also explored Service discovery through Kubernetes DNS, tested internal Pod-to-Service communication, inspected Endpoints and EndpointSlices, and compared the three Service types.

## Environment

| Component | Version / Configuration |
|---|---|
| Operating System | Windows 11 |
| Terminal | Git Bash |
| Container Runtime | Docker Desktop |
| Kubernetes Tool | kubectl v1.36.1 |
| Kubernetes Cluster | KIND |
| Kubernetes Version | v1.37.0 |
| Cluster Name | devops-cluster |
| Nodes | 1 Control Plane + 1 Worker |
| Application | Nginx 1.25 |

## 1. Deploy the Application

Created a Deployment named `web-app` with three replicas using the Nginx 1.25 image.

### Manifest: `app-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

Applied the Deployment:

```bash
kubectl apply -f app-deployment.yaml
```

Verified the Deployment and Pods:

```bash
kubectl get deployments
kubectl get pods -o wide
```

All three Nginx Pods reached the Running and Ready state.

### Important Concept: containerPort

`containerPort: 80` documents the port that the container is expected to listen on.

It does not independently expose the application outside the Pod or create a Kubernetes Service.

## 2. ClusterIP Service

ClusterIP is the default Kubernetes Service type.

It exposes an application through an internal IP address, allowing communication from within the Kubernetes cluster.

Created a ClusterIP Service named `web-app-clusterip`.

### Manifest: `clusterip-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
```

Applied the Service:

```bash
kubectl apply -f clusterip-service.yaml
```

Verified the Service:

```bash
kubectl get services
kubectl describe svc web-app-clusterip
kubectl get endpoints web-app-clusterip
```

Observed ClusterIP:

```text
10.96.40.227
```

The Service discovered all three Nginx Pods through the selector:

```yaml
selector:
  app: web-app
```

### Understanding Service Ports

| Field | Value | Meaning |
|---|---|---|
| port | 80 | Port exposed by the Service |
| targetPort | 80 | Destination port on the application Pod |
| containerPort | 80 | Declared container port |

The Service forwards traffic received on port 80 to the application Pods on port 80.

The `containerPort` declaration is optional for Service forwarding, provided the application is actually listening on the target port.

### Test Internal Connectivity

Started a temporary BusyBox Pod:

```bash
kubectl run test-client --image=busybox:latest --rm -it --restart=Never -- sh
```

Inside the BusyBox container:

```bash
wget -qO- http://web-app-clusterip
```

The Nginx welcome page HTML was returned successfully.

This verified internal Pod-to-Service communication.

## 3. Kubernetes Service DNS

Kubernetes provides DNS-based Service discovery through CoreDNS.

Instead of remembering the Service ClusterIP, applications can communicate using the Service DNS name.

Started a temporary BusyBox Pod:

```bash
kubectl run dns-test --image=busybox:latest --rm -it --restart=Never -- sh
```

Inside the container:

```bash
nslookup web-app-clusterip
```

Observed DNS information included:

```text
Server: 10.96.0.10
Address: 10.96.0.10:53

Name: web-app-clusterip.default.svc.cluster.local
Address: 10.96.40.227
```

The full Service DNS name was:

```text
web-app-clusterip.default.svc.cluster.local
```

### DNS Name Structure

```text
<service-name>.<namespace>.svc.cluster.local
```

| Component | Meaning |
|---|---|
| web-app-clusterip | Service name |
| default | Namespace |
| svc | Kubernetes Service |
| cluster.local | Cluster DNS domain |

The DNS server address `10.96.0.10` was the CoreDNS Service IP observed in the output.

### Important Concepts

- Services have stable DNS names.
- A Service DNS name resolves to the Service ClusterIP.
- Pods can be replaced and receive new IP addresses.
- The Service name and ClusterIP remain stable while the Service exists.
- EndpointSlice maintains the backend Pod addresses for the Service.

The BusyBox `nslookup` output also showed NXDOMAIN responses for some search-domain candidates before resolving the full Service name. The full DNS name resolved successfully.

## 4. NodePort Service

NodePort exposes a Service through a port on the Kubernetes nodes.

Created a NodePort Service named `web-app-nodeport`.

### Manifest: `nodeport-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

Applied the Service:

```bash
kubectl apply -f nodeport-service.yaml
```

Verified:

```bash
kubectl get services
kubectl describe svc web-app-nodeport
kubectl get endpoints web-app-nodeport
```

Observed:

```text
TYPE: NodePort
CLUSTER-IP: 10.96.190.74
PORT(S): 80:30080/TCP
```

### Understanding NodePort Traffic

| Field | Value | Meaning |
|---|---|---|
| nodePort | 30080 | Port exposed on Kubernetes nodes |
| port | 80 | Service port |
| targetPort | 80 | Application Pod destination port |

Conceptual traffic flow:

```text
External Client
      |
      | Node IP : 30080
      |
      v
  NodePort Service
      |
      | Service Port : 80
      |
      v
  Application Pod
      |
      | Target Port : 80
      |
      v
    Nginx
```

### Testing NodePort in KIND

KIND runs Kubernetes nodes as Docker containers.

Checked the cluster node containers:

```bash
docker ps
```

Entered the worker node:

```bash
docker exec -it devops-cluster-worker bash
```

Inside the worker node:

```bash
curl http://localhost:30080
```

The Nginx welcome page HTML was returned successfully.

This verified that NodePort was working from inside the KIND worker node.

### KIND Networking Observation

The KIND cluster was created without `extraPortMappings`.

Therefore, Docker Desktop did not publish port 30080 to the Windows host.

The NodePort was verified at the worker-node level, but direct Windows host access through `localhost:30080` was not configured or verified.

## 5. LoadBalancer Service

LoadBalancer is a Kubernetes Service type designed to integrate with an external load-balancing implementation.

Created a Service named `web-app-loadbalancer`.

### Manifest: `loadbalancer-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
```

Applied the Service:

```bash
kubectl apply -f loadbalancer-service.yaml
```

Verified:

```bash
kubectl get svc web-app-loadbalancer
kubectl describe svc web-app-loadbalancer
kubectl get endpoints web-app-loadbalancer
```

Observed output:

```text
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
web-app-loadbalancer   LoadBalancer   10.96.212.36   <pending>     80:32585/TCP
```

### Understanding the Output

| Field | Value | Meaning |
|---|---|---|
| Type | LoadBalancer | Service type |
| ClusterIP | 10.96.212.36 | Internal Service IP |
| External IP | Pending | No external load balancer assigned |
| Port | 80 | Service port |
| NodePort | 32585 | Allocated node port |
| TargetPort | 80 | Application Pod port |

### Why Was External IP Pending?

The Kubernetes cluster was running locally using KIND and Docker Desktop.

There was no external cloud load-balancer integration configured for this cluster.

Therefore, Kubernetes could not provision an external load balancer, and the External IP remained `<pending>`.

This was expected behavior in this local environment.

In AWS EKS, a LoadBalancer Service can integrate with AWS infrastructure to provision a Network Load Balancer when the appropriate AWS integration is configured.

An Application Load Balancer is commonly provisioned through the AWS Load Balancer Controller using Ingress or Gateway resources.

## 6. Compare Kubernetes Service Types

Executed:

```bash
kubectl get services -o wide
```

Observed:

```text
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
kubernetes             ClusterIP      10.96.0.1      <none>        443/TCP
web-app-clusterip      ClusterIP      10.96.40.227   <none>        80/TCP
web-app-loadbalancer   LoadBalancer   10.96.212.36   <pending>     80:32585/TCP
web-app-nodeport       NodePort       10.96.190.74   <none>        80:30080/TCP
```

### Comparison Table

| Feature | ClusterIP | NodePort | LoadBalancer |
|---|---|---|---|
| Internal ClusterIP | Yes | Yes | Yes |
| NodePort | No | Yes | Usually allocated by default |
| External Load Balancer | No | No | Requested |
| Internal communication | Yes | Yes | Yes |
| External access | Not directly | Through node IP and NodePort | Through external load balancer when provisioned |

### Key Differences

**ClusterIP**

- Default Service type.
- Used for internal cluster communication.
- Commonly used for backend and database Services.

**NodePort**

- Exposes the Service through a port on each eligible node.
- Can be used for external access and development/testing.
- Also supports internal ClusterIP communication.

**LoadBalancer**

- Requests an external load balancer through the configured infrastructure integration.
- Also has a ClusterIP.
- Normally receives a NodePort allocation by default, unless NodePort allocation is disabled or handled differently by the implementation.

## 7. EndpointSlices

EndpointSlices provide information about the network endpoints associated with a Kubernetes Service.

Inspected EndpointSlices using:

```bash
kubectl get endpointslices -l kubernetes.io/service-name=web-app-clusterip
kubectl get endpointslices -l kubernetes.io/service-name=web-app-nodeport
kubectl get endpointslices -l kubernetes.io/service-name=web-app-loadbalancer
```

All three Services showed the same three backend Pod IPs:

```text
10.244.1.2
10.244.1.3
10.244.1.4
```

Each EndpointSlice showed port 80.

### Why Are EndpointSlices Important?

- They maintain backend endpoint information for Services.
- Kubernetes updates endpoint information as matching Pods become eligible or unavailable.
- Services use this endpoint information to direct traffic to backend Pods.
- They help Services continue working when Deployment-managed Pods are replaced.

The older `Endpoints` API also worked during this lab, but Kubernetes displayed a deprecation warning because EndpointSlices are the recommended API.

## 8. Cleanup

Deleted all Day 53 application resources:

```bash
kubectl delete -f app-deployment.yaml
kubectl delete -f clusterip-service.yaml
kubectl delete -f nodeport-service.yaml
kubectl delete -f loadbalancer-service.yaml
```

Verified cleanup:

```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

Observed:

```text
No resources found in default namespace.

NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP

No resources found in default namespace.
```

All application resources were successfully deleted. The default Kubernetes Service remained intact.

## 9. Screenshots

| Screenshot | Description |
|---|---|
| 01-deployment-and-pod-ips.png | Three-replica Nginx Deployment and Pod IPs |
| 02-clusterip-service-and-endpoints.png | ClusterIP Service and its endpoints |
| 03-clusterip-internal-connectivity.png | Internal connectivity test using BusyBox |
| 04-kubernetes-service-dns.png | Kubernetes Service DNS lookup |
| 05-nodeport-service-created.png | NodePort Service configuration |
| 06-nodeport-node-level-access.png | NodePort connectivity from KIND worker |
| 07-loadbalancer-service-created.png | LoadBalancer Service configuration |
| 08-services-comparison.png | Service types and EndpointSlice comparison |
| 09-day53-cleanup.png | Final resource cleanup verification |

Screenshots are available in the `screenshots/` directory.

## 10. Key Learnings

1. Understood the purpose of Kubernetes Services.
2. Learned how ClusterIP provides internal Service access.
3. Practiced Pod-to-Service communication using BusyBox.
4. Understood Kubernetes Service DNS and CoreDNS.
5. Learned how NodePort exposes Services through Kubernetes nodes.
6. Understood the relationship between `containerPort`, `port`, `targetPort`, and `nodePort`.
7. Explored LoadBalancer behavior in a local KIND cluster.
8. Compared ClusterIP, NodePort, and LoadBalancer.
9. Inspected Service endpoints and EndpointSlices.
10. Learned how Services continue routing traffic when Deployment-managed Pods are replaced.

## Conclusion

Successfully completed Day 53 of the 90 Days of DevOps challenge.

Created and tested ClusterIP, NodePort, and LoadBalancer Services using a three-replica Nginx Deployment in a local KIND cluster.

Verified internal communication, DNS resolution, node-level access, EndpointSlices, and resource cleanup.

This hands-on exercise improved my understanding of Kubernetes Service networking and application exposure.