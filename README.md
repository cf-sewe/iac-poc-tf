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
> todo: example layout for supporting multiple environments with Terraform

## Multi-Cloud Support
> todo: example layout for supporting multiple cloud providers with Terraform

## Differences to cplace-poc
There are a few differences in regard to the existing state of the [cplace-poc](https://github.com/collaborationFactory/cplace-kubernetes)
which should be mentioned. These are made consciously and with respect to stable/secure production operation.

* using [prometheus-operator](https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html)
  instead of prometheus, grafana individually.
    * [also see helm](https://github.com/helm/charts/tree/master/stable/prometheus-operator)
    * bundles Grafana and dashboards
    * uses [CustomResourceDefinitions (CRD)](https://github.com/coreos/prometheus-operator#customresourcedefinitions)
    * uses ServiceMonitor CRD instead of Annotations for configuration 
* using environment specific subdomain `xxx.poc.cplace.xyz`
* using wildcard domain and wildcard certificate
    * therefore currently no `cert-manager` needed
* using AWS NLB Loadbalancer with HTTPS termination
+ access to the k8s cluster (e.g. via kubectl) is only possible from the EC2 deployer instance

## Open Topics

* User management to allow kubernetes cluster access (with fine grained permissions, not everybody is supposed to be admin)
* Private ingress controller (VPC internal)
* Investigate [Traefik 2.2](https://github.com/containous/traefik-helm-chart) as replacement candidate for nginx-ingress
* Egress controller (all outgoing traffic should be going through it)
    * ideally traffic to internet is by default not possible, only whitelisted destinations
* Determine and Configure Resource Limits (CPU/Memory, to ensure proper scalability)
* Forward Alerts to Slack 
    * via Grafana
    * via kube-slack
