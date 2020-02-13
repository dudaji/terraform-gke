locals {
  predifined_macine_type = length(var.machine_type) > 2
  node_pool_count        = local.predifined_macine_type ? min(1, var.node_pool_count) : var.node_pool_count
  gpu                    = length(var.gpu_type) > 0
  cpu                    = [for i in range(local.node_pool_count) : pow(2, var.cpu_start_exponent + (var.machine_type == "e2" ? i + 1 : i))]
  memory                 = [for i in range(local.node_pool_count) : (pow(2, i) + var.memory_start_exponent) * var.memory_coefficient]
  machine_type           = [for i in range(local.node_pool_count) : local.predifined_macine_type ? var.machine_type : format("%s-custom-%d-%d", var.machine_type, local.cpu[i], local.memory[i])]
  name                   = [for i in range(local.node_pool_count) : local.predifined_macine_type ? var.machine_type : format("%s%s", local.name_gpu_prefix[i], local.machine_type[i])]
  name_gpu_prefix        = [for i in range(local.node_pool_count) : local.gpu ? format("%s-%d-", var.gpu_type, local.gpu_count[i]) : ""]
  gpu_count              = [for i in range(local.node_pool_count) : local.gpu ? pow(2, i) : 0]
}
