output "kapsule_cluster_id" {
    value       = scaleway_k8s_cluster.kapsule-kong.id
    description = "The id of our cluster."
}

output "kapsule_cluster_region" {
    value       = scaleway_k8s_cluster.kapsule-kong.region
    description = "The region of our cluster."
}

output "autscaling_id" {
    value       = scaleway_k8s_pool.kapsule-kong.id
    description = "The id of our instance pool."
}
