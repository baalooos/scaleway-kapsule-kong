# Install Kong Gateway on Kapsule and send your metrics to Observability

In this article, we will install Kong Gateway in a Kapsule Cluster. We will also send our Kong metrics to Observability and use Grafana to present them in a nice and useful way.

!!!!!!!!
Following the pricing problem with Observability, do we need to give more informations on pricing?
!!!!!!!!

## Prior Knowledge

In ordre to better understand this article, one must be knowledgeable in the following topics:

- [Kubernetes]([Kubernetes](https://kubernetes.io/))
- [Prometheus](https://prometheus.io/)

We will also use the following tools:

- [Kong Gateway](https://konghq.com/products/kong-gateway)
- [Grafana](https://grafana.com/)

## What is Kong Gateway?

Kong Gateway is a light and fast **Cloud Native API Gateway**. An API Gateway is a reverse proxy allowing you to manage, configure and route requests to your APIs. Kong Gateway is build to work in a decentralised way and to stand in front of your REST APIs.

Thanks to an integrated Ingress Controller, Kong Gateway is natively compatible with Kubernetes.

For more informations, please refere to the official [Kong Documentation](https://docs.konghq.com/). You can find more informations on Kong Gateway [here](https://docs.konghq.com/gateway/3.0.x/).

## What is Observability?

Cockpit is a monitoring and alerting solution designed for multi-source observability. Cockpit allows you to collect, store, and analyze metrics and logs from Scaleway resources and from external resources.

Cockpit est un produit Scaleway permettant de faire de l’observabilité. Il propose plusieurs fonctionnalités intéressantes.
Tout d’abord, il va vous permettre de centraliser les métriques et les logs des produits Scaleway pour vos différents services. Ceci vous permet d’avoir un monitoring natif de nos services sans actions supplémentaires de votre part.
La seconde fonctionnalité, celle qui va nous intéresser aujourd’hui, permet de stocker chez Scaleway les métriques et les logs générés par vos applications. Cet envoi se fait grâce à des endpoints disponibles via la console, dans Cockpit et permet de pousser des métriques vers un endpoint Prometheus compatible, et les logs vers un endpoint Loki compatible.
Ces logs et ces métriques pourront ensuite être consultés grâce à une instance Grafana qui vous est dédiée. A l’intérieur de cette instance vous trouverez des dashboards par défaut, permettant de visualiser les données provenant de Scaleway. Vous avez aussi la possibilité de créer ou d’importer des dashboards afin de pouvoir  exploiter les données que vous envoyez depuis vos applications.
Une dernière fonctionnalité est Alert Manager. Il s’agit d’une interface vous permettant de gérer les alertes.
Pour plus d’informations, vous pouvez vous référez à la documentation disponible ici (https://www.scaleway.com/en/docs/observability/cockpit/ ).

## Qu’est-ce que Grafana Agent?

Grafana Agent est un utilitaire développé par la société Grafana en marge de son offre d’hébergement afin d’envoyer des métriques vers des endpoints compatibles. Grafana Agent est compatible avec la découverte de services Prometheus, ce qui permet de l’utiliser sur une infrastructure existante sans modifier ce qui tourne déjà.
Dans la suite de cet article, nous allons voir comment utiliser Grafana Agent pour récolter les métriques mises à disposition par Kong, et les envoyer vers le produit Observability.

## Prérequis

Pour la suite de cette article, vous aurez besoin:
d’un compte Scaleway
d’un cluster Kubernetes avec au moins un serveur disponible
d’un Cockpit configuré au travers du produit Observability (https://www.scaleway.com/en/docs/observability/cockpit/quickstart/ )
Dans mon cas j’utilise un cluster Kapsule (https://www.scaleway.com/en/docs/containers/kubernetes/quickstart/ ), la solution de Kubernetes managé de Scaleway, mais l’exemple que nous allons déployé devrait fonctionner sur des clusters Kubernetes hébergés chez d’autres Cloud Provider et même sur des clusters Kubernetes tournant dans vos datacenters.

Tous les fichiers que nous allons utiliser sont disponibles sur ce repo Github: https://github.com/baalooos/scaleway-kapsule-kong

## Installation de Kong

### Création du namespace pour Kong

```shell
➜  ~ kubectl create namespace kong
namespace/kong created
```

### Add kong repository

```shell
➜  ~ helm repo add kong https://charts.konghq.com
"kong" has been added to your repositories
➜  ~ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kong" chart repository
Update Complete. ⎈Happy Helming!⎈
```

### Deploy Kong

```shell
➜  ~ helm install mykong kong/kong --namespace kong --set serviceMonitor.enabled=true --set serviceMonitor.labels.release=promstack
NAME: mykong
LAST DEPLOYED: Tue Dec 13 16:59:14 2022
NAMESPACE: kong
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
To connect to Kong, please execute the following commands:

HOST=$(kubectl get svc --namespace kong mykong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(kubectl get svc --namespace kong mykong-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP

Once installed, please follow along the getting started guide to start using
Kong: https://docs.konghq.com/kubernetes-ingress-controller/latest/guides/getting-started/
```

### Deploy Custom configuration for Kong

```shell
➜  ~ cd k8s
➜  ~ kubectl apply -f KongClusterPlugin.yaml  kongclusterplugin.configuration.konghq.com/prometheus created
```

## Installation de Grafana Agent

```shell
➜  ~ kubectl apply -f GrafanaAgentConfig.yaml
namespace/grafana created
configmap/grafana-agent created
```

```shell
➜  ~ kubectl apply -f GrafanaAgentDeploy.yaml
serviceaccount/grafana-agent created
clusterrole.rbac.authorization.k8s.io/grafana-agent created
clusterrolebinding.rbac.authorization.k8s.io/grafana-agent created
service/grafana-agent created
statefulset.apps/grafana-agent created
```

## Deploy a dummy application

```shell
➜  ~ kubectl apply -f ServiceIngress.yaml
service/httpbin created
ingress.networking.k8s.io/demo created
```

## Test

Récupérer l’IP de notre ingress:

```shell
kubectl get ing
NAME    CLASS    HOSTS   ADDRESS         PORTS   AGE
demo    <none>   *       51.159.27.117   80      7d
```

On peut ensuite essayer d’appeler notre ingress.

➜  ~ curl -k 51.159.27.117/foo/ip
{
  "origin": "172.16.16.3, 51.15.219.42"
}
➜  ~ curl -k 51.159.27.117/foo/uuid
{
  "uuid": "6d9cad88-4fe7-4621-be92-ccf574a87fa2"
}
➜  ~ curl -k 51.159.27.117/foo/user-agent
{
  "user-agent": "curl/7.88.1"
}



## Résultats
