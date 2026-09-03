#!/bin/bash

set -e

echo "======================================"
echo "Creating Kubernetes Learning Cluster"
echo "======================================"

# Create 1 control-plane + 3 worker nodes
echo ""
echo "Creating 4-node Minikube cluster..."

minikube start \
    -p microservice-app \
    --nodes 4 \
    --driver=docker

echo ""
echo "Cluster created."
echo ""

# Label worker nodes
echo "Assigning workload roles..."

kubectl label node microservice-app-m02 role=frontend --overwrite
kubectl label node microservice-app-m03 role=backend --overwrite
kubectl label node microservice-app-m04 role=database --overwrite

echo ""
echo "======================================"
echo "Cluster Nodes"
echo "======================================"

kubectl get nodes -L role

echo ""
echo "======================================"
echo "Node Mapping"
echo "======================================"

echo "microservice-app      -> Control Plane"
echo "microservice-app-m02  -> Frontend"
echo "microservice-app-m03  -> Backend"
echo "microservice-app-m04  -> Database"

echo ""
echo "Cluster setup complete!"