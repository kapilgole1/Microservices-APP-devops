# Microservices DevOps Project

This repository contains a NestJS task-management microservices application and its DevOps deployment setup.

## Attribution

The web application and microservices development code are based on the original project by **Denrox**:

<https://github.com/Denrox/nestjs-microservices-example>

My contribution is limited to the DevOps implementation:

- GitHub Actions CI/CD
- Docker and Docker Hub image publishing
- Kubernetes and Minikube deployment
- Kustomize manifests
- Argo CD GitOps synchronization
- Kubernetes secret management

## DevOps Workflow

```text
GitHub push or manual dispatch
        -> GitHub Actions builds and tests services
        -> Docker images are pushed to Docker Hub
        -> Kustomize updates image tags with the commit SHA
        -> Argo CD detects the Git change
        -> Kubernetes deploys the new version
```

## Tools and Learning

| Tool | What I implemented or learned |
| --- | --- |
| GitHub Actions | Automated dependency installation, image building, publishing, and manifest updates |
| Docker | Containerized each microservice and compiled applications during image creation |
| Docker Hub | Stored `gateway`, `mailer`, `permission`, `task`, `token`, and `user` images |
| Kubernetes | Managed Deployments, Services, Secrets, ConfigMaps, StatefulSet, and persistent storage |
| Minikube | Created a local four-node Kubernetes cluster with node labels |
| Kustomize | Managed resources and reproducible commit-SHA image tags |
| Argo CD | Applied GitOps synchronization from the `master` branch |

## Deployment Screenshots

### Kubernetes Nodes

![Kubernetes nodes](Node.png)

### Application Pods

![Application pods](Pods.png)

### Argo CD

![Argo CD application](Argo-CD.png)

## Required Tools

- Docker and Docker Compose
- Node.js 18+
- kubectl
- Minikube
- Git
- Argo CD

## Local Kubernetes Deployment

Run from the repository root:

```bash
minikube start --profile=microservice-app --driver=docker --nodes=4
kubectl config use-context microservice-app

cd k8s-manifests
kubectl apply -k .
kubectl get nodes -o wide -L role
kubectl get pods -n web-app-k8s -o wide
```

The database node uses the label `role=database` for MongoDB scheduling.

## Argo CD Application

The Argo CD manifest is [k8s-manifests/argocd-application.yaml](k8s-manifests/argocd-application.yaml). It watches:

| Setting | Value |
| --- | --- |
| Repository | `https://github.com/kapilgole1/Microservices-APP-devops.git` |
| Branch | `master` |
| Path | `k8s-manifests` |
| Namespace | `web-app-k8s` |
| Sync policy | Automated sync, prune, and self-heal |

Check Argo CD:

```bash
kubectl get application microservice-app -n argocd -o wide
kubectl get pods -n argocd
```

## GitHub Actions Secrets

Add these values under **GitHub repository > Settings > Secrets and variables > Actions**:

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub username or organization |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

The workflow requires repository write permission to commit updated Kustomize tags:

```yaml
permissions:
  contents: write
```

Manual runs are enabled with `workflow_dispatch`.

## Kubernetes Secret Management

Do not commit real passwords or tokens. Runtime secret keys are:

| Secret | Keys |
| --- | --- |
| `app-secret` | `JWT_SECRET`, `MAILER_DSN`, `MAILER_FROM` |
| `mongo-secret` | `MONGO_INITDB_ROOT_USERNAME`, `MONGO_INITDB_ROOT_PASSWORD`, `MONGO_DSN` |

For production, store these values in a secret manager such as AWS Secrets Manager and load them with External Secrets Operator or Sealed Secrets. GitHub Actions Secrets are for CI authentication; they are not automatically available inside Kubernetes pods.

## Access the API

```bash
kubectl port-forward -n web-app-k8s svc/gateway-service 8000:8000
```

Open <http://localhost:8000/api> for Swagger.

## Useful Checks

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -n web-app-k8s
kubectl get deployments,statefulsets -n web-app-k8s
kubectl get events -n web-app-k8s --sort-by=.lastTimestamp
kubectl get application microservice-app -n argocd -o wide
```

Remove the local cluster when finished:

```bash
minikube delete -p microservice-app
```
