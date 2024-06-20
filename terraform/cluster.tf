resource "scaleway_k8s_cluster" "kapsule-kong" {
    name    = "kapsule-kong"
    version = "1.24.7"
    cni     = "cilium"
}

resource "scaleway_k8s_pool" "kapsule-kong" {
    cluster_id = scaleway_k8s_cluster.kapsule-kong.id
    name       = "kapsule-kong"
    node_type  = "PLAY2-NANO"
    size       = 1
}
