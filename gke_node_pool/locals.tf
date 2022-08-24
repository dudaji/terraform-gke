locals {
  gpu                     = length(var.gpu_type) > 0
  predifined_macine_type  = length(var.machine_type) > 2
  name_preemptible_prefix = var.preemptible ? "pr-" : ""
  node_pool_count         = local.predifined_macine_type ? min(1, var.node_pool_count) : var.node_pool_count
  cpu                     = [for i in range(local.node_pool_count) : pow(2, var.cpu_start_exponent + (var.machine_type == "e2" ? max(1, i) : i))]
  memory                  = [for i in range(local.node_pool_count) : pow(2, i + var.memory_start_exponent) * var.memory_coefficient]
  machine_type            = [for i in range(local.node_pool_count) : local.predifined_macine_type ? var.machine_type : format("%s-custom-%d-%d", var.machine_type, local.cpu[i], local.memory[i])]
  name                    = [for i in range(local.node_pool_count) : format("%s%s%s", local.name_preemptible_prefix, local.name_gpu_prefix[i], local.machine_type[i])]
  name_gpu_prefix         = [for i in range(local.node_pool_count) : local.gpu ? format("%s-%d-", trimprefix(var.gpu_type, "nvidia-tesla-"), local.gpu_count[i]) : ""]
  gpu_count               = [for i in range(local.node_pool_count) : local.gpu ? pow(2, i) : 0]
}
