# GKE GPU AUTOSCALE TERRAFORM

## 설명

Google cloud platform에서 Scaleable한 gpu cluster를 만드는 Terraform 예제입니다.

## 좋은 점

**필요한 만큼만 gpu를 사용하기 쉽다.**

2019년 5월 기준

V100 구매시 $10,000 이상입니다.  
GCP에서 V100 GPU 시간당 가격은 $2.48 선점형일 경우 \$0.74 입니다.  
장비를 구입하지 않아도 필요한 만큼만 사용할 수 있습니다.

## 주의

**아래 예제를 실행할 경우 요금이 발생합니다.** 다 사용한 cluster는 삭제 해주세요.

## Getting Started

```
git clone https://github.com/dudaji/gke-gpu-auto-scale.git
cd gke-gpu-auto-scale
```

key.json credential file이 필요합니다.

test/provider.tf

```
variable "project" {
  default = "project-name"
}

provider "google" {
  credentials = "${file("../key.json")}"
  project     = "${var.project}"
  zone        = "us-central1-c"
}
```

test directory에서 terraform plan을 해보시면 생성되는 resource를 보실 수 있습니다.

```
$ cd test
$ terraform plan
...
      node_config.0.oauth_scopes.172152165:            "https://www.googleapis.com/auth/logging.write"
      node_config.0.preemptible:                       "true"
      node_config.0.service_account:                   <computed>
      node_count:                                      "0"
      project:                                         <computed>
      region:                                          <computed>
      version:                                         <computed>
      zone:                                            <computed>


Plan: 9 to add, 0 to change, 0 to destroy.
```

gke cluster를 만들겠습니다. (\$PROJECT_NAME을 변경해주세요)

```
$ terraform apply -var 'project=$PROJECT_NAME'
Plan: 9 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

생성 중인 화면입니다.  
10분 소요됩니다.

```
module.gke.google_container_cluster.ml_cluster: Creating...
  additional_zones.#:                   "" => "<computed>"
  addons_config.#:                      "" => "<computed>"
  cluster_autoscaling.#:                "" => "<computed>"
  cluster_ipv4_cidr:                    "" => "<computed>"
  enable_binary_authorization:          "" => "<computed>"
  enable_kubernetes_alpha:              "" => "false"
  enable_legacy_abac:                   "" => "false"
  enable_tpu:                           "" => "<computed>"
  endpoint:                             "" => "<computed>"
  initial_node_count:                   "" => "1"
  instance_group_urls.#:                "" => "<computed>"
  ip_allocation_policy.#:               "" => "<computed>"
  location:                             "" => "us-central1-c"
  logging_service:                      "" => "none"
  master_auth.#:                        "" => "1"
  master_auth.0.client_certificate:     "" => "<computed>"
```

생성되고 나면 gcp 콘솔이 보입니다.
![gke-cluster](https://www.arangodb.com/docs/3.4/images/gke-clusters.png)

### nvidia driver install Daemonset

Cluster가 생성된 후에는

https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#installing_drivers  
에 따라서 nvidia drive를 install 해주는 daemonset을 생성합니다.

```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/stable/nvidia-driver-installer/cos/daemonset-preloaded.yaml
```

### Gpu Pod Test

현재 node 상태입니다.

```
$ kubectl get nodes
NAME                           STATUS   ROLES    AGE   VERSION
gke-test-cpu-1-131599f3-8p2l   Ready    <none>   16m   v1.12.7-gke.10
```

아래 pod 을 생성합니다.

```
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  restartPolicy: Never
  containers:
    - name: gpu-container
      image: nvidia/cuda:10.0-base
      command:
      - nvidia-smi
      resources:
        limits:
          nvidia.com/gpu: 1
```

상태를 보면 gpu 노드가 없어 Trigger scale up 합니다.

```
$ kubectl describe pod


Events:
  Type     Reason            Age                From                Message
  ----     ------            ----               ----                -------
  Warning  FailedScheduling  53s (x2 over 54s)  default-scheduler   0/1 nodes are available: 1 Insufficient nvidia.com/gpu.
  Normal   TriggeredScaleUp  12s                cluster-autoscaler  pod triggered scale-up: [{https://content.googleapis.com/compute/v1/projects/my-project/zones/us-central1-c/instanceGroups/gke-test-nvidia-tesla-k80-1-dae0ecbd-jkzd 0->1 (max: 8)}]
```

그리고 다시 노드들을 조회하면 gpu 노드가 생성된 걸 볼 수 있습니다.

```
$ kubectl get nodes
NAME                                        STATUS   ROLES    AGE   VERSION
gke-test-cpu-1-131599f3-8p2l                Ready    <none>   17m   v1.12.7-gke.10
gke-test-nvidia-tesla-k80-1-dae0ecbd-jkzd   Ready    <none>   19s   v1.12.7-gke.10
```

Node가 추가되면 아까 생성했던 nvidia-driver install daemonset이 nvidia driver를 인스톨합니다.

```
kubectl get pods -n kube-system
NAME                                                   READY   STATUS     RESTARTS   AGE
nvidia-driver-installer-kxf2b                          0/1     Init:0/1   0          38s


$ kubectl logs nvidia-driver-installer-kxf2b -c nvidia-driver-installer
...
[INFO    2019-05-20 06:33:27 UTC] Updated cached version as:
CACHE_BUILD_ID=10895.211.0
CACHE_NVIDIA_DRIVER_VERSION=410.79
[INFO    2019-05-20 06:33:27 UTC] Verifying Nvidia installation
Mon May 20 06:33:32 2019
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 410.79       Driver Version: 410.79       CUDA Version: 10.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla K80           Off  | 00000000:00:04.0 Off |                    0 |
| N/A   37C    P0    81W / 149W |      0MiB / 11441MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  Tesla K80           Off  | 00000000:00:05.0 Off |                    0 |
| N/A   34C    P0    66W / 149W |      0MiB / 11441MiB |    100%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
[INFO    2019-05-20 06:33:32 UTC] Finished installing the drivers.
[INFO    2019-05-20 06:33:32 UTC] Updating host's ld cache
```

그리고 Pod은 정상적으로 Assign되고 로그를 살펴보면 아래와 같습니다.

```
$ kubectl logs gpu-pod
Mon May 20 06:53:23 2019
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 410.79       Driver Version: 410.79       CUDA Version: 10.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla K80           Off  | 00000000:00:04.0 Off |                    0 |
| N/A   59C    P8    31W / 149W |      0MiB / 11441MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

gpu를 사용하는 pod을 삭제하고 5분 정도 기다리면 gpu node가 사라집니다.

```
❯ kubectl delete pod --all
pod "gpu-pod" deleted

❯ kubectl get nodes
NAME                           STATUS   ROLES    AGE   VERSION
gke-test-cpu-1-131599f3-8p2l   Ready    <none>   57m   v1.12.7-gke.10
```

### Clean up

terraform destroy

```
$ terraform destroy

...

Plan: 0 to add, 0 to change, 9 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

혹은 gcp console에서 삭제하셔도 됩니다.

## 시행 착오

1. master 의 경우에는 GCP에서 제공해줍니다. (GCP free tier에 포함되어 있음)  
   하지만 최소 g1-small 정도의 node 1개는 떠 있어야 api server에 요청이 왔을 때  
   management 기능이 작동합니다. 그렇지 않으면 Unscheduable 한 상태로 계속 머물러 있습니다.

2. 메모리가 부족할 경우 OOM이 발생합니다. 그래서 메모리를 넉넉하게 1코어당 5G까지 주었습니다.

## Limitation

Node 가 Scale up 혹은 down되는데 5분 정도 소요됩니다.

그 사이에 스케쥴이 맞물리면 Fragment가 발생할 가능성이 있습니다.

```
limit:
  nvidia.com/gpu: 1
```

예를 들어 gpu 4개 짜리 작업이 끝나고 Node가 Scale down되기를 기다리고 있을때  
gpu 1개를 사용하는 요청이 들어오면 gpu 4개 짜리 Node에 Assign 됩니다.

gpu node 에는 taints가 아래와 같이 적용되어 있기 때문입니다.

```
NO_SCHEDULE	nvidia.com/gpu=present
```

실제로는 gpu 1개를 사용하더라도 node에는 gpu가 4개 있으므로 3개는 놀게 됩니다.

그래서 distributed learning 보다는 더 좋은 gpu 1개를 사용하거나  
tpu를 사용하는게 좋을 것으로 보입니다. (가성비도 더 좋습니다)

예를 들면 P100 X 4 -> V100 1개  
혹은 V100 8개 멀티 cluster -> v2-32 Cloud TPU v2 Pod 1개
