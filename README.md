# Introduction

This repository implements a Proof of Concept for Terraform infrastructure automation for the AWS cloud.
It manages components in the AWS infrastructure.

# Bootstrapping

See [here](bootstrap/README.md)

# EKS Cluster Management

See [here](eks/README.md)

# Other

## Deploying cplace

Probably its a good idea if the application deployment is handled separately from Cluster management. 
The possibility that something goes wrong (e.g. accidental deletion of Kubernetes cluster) is lower and separation of
concern.

Several GitOps solutions possible
* fluxcd 
* atlantis
* terraform cloud


## Environment Support
## Multi-Cloud Support 
