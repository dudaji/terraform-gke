# Terraform gke node pool

## Example

see [example](./example/main.tf)

```terraform
module "cpu-pool" {
  source       = "github.com/dudaji/terraform-gke-node-pool"
  cluster      = "${google_container_cluster.ml_cluster.name}"
  location     = local.location
  node_count   = 1
  machine_type = "g1-small"
}
```

will create g1-small node pool

```console
+ machine_type      = "g1-small"
```

---

```terraform
module "cpu-pool" {
  source       = "github.com/dudaji/terraform-gke-node-pool"
  cluster      = "${google_container_cluster.ml_cluster.name}"
  location     = local.location
  node_count   = 1
  node_pool_count    = 2
  machine_type       = "n1"
}
```

will create

```console
+ machine_type      = "n1-custom-1-1024"
+ machine_type      = "n1-custom-2-2048"
+ machine_type      = "n1-custom-4-4096"
+ machine_type      = "n1-custom-8-8192"
```

---

```terraform
module "gpu-pool" {
  source       = "github.com/dudaji/terraform-gke-node-pool"
  cluster            = "${google_container_cluster.ml_cluster.name}"
  location           = local.location
  node_pool_count    = 4
  machine_type       = "n1"
  cpu_start_exponent = 2
  memory_coefficient = 1024 * 16
  gpu_type           = "nvidia-tesla-t4" # for gpu
}
```

will create

```console
+ machine_type      = "n1-custom-4-16384"
+ guest_accelerator = [
          + {
              + count = 1
              + type  = "nvidia-tesla-t4"
            },
        ]
+ machine_type      = "n1-custom-8-32768"
+ guest_accelerator = [
          + {
              + count = 2
              + type  = "nvidia-tesla-t4"
            },
        ]
+ machine_type      = "n1-custom-16-65536"
+ guest_accelerator = [
          + {
              + count = 4
              + type  = "nvidia-tesla-t4"
            },
        ]
+ machine_type      = "n1-custom-32-131072"
+ guest_accelerator = [
          + {
              + count = 8
              + type  = "nvidia-tesla-t4"
            },
        ]
```

## Module versioning

[select versioning](https://www.terraform.io/docs/modules/sources.html#selecting-a-revision)
```
source = "git::https://github.com/dudaji/terraform-gke//gke_node_pool?ref=v0.1.0"
```
