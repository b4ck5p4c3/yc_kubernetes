# Deploy K8s with terraform

### Requirements:
* OpenTofu
* Yandex Cloud CLI
* jq

### Yandex Cloud CLI installation
* MacOS:
  * Quick: `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`
  * Brew: `brew install yandex-cloud-cli`
* Linux:
  * Quick: `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`
  * Other: Seek your distro repos!

See: https://yandex.cloud/en-ru/docs/cli/quickstart#install

## Yandex Provider setup:
1. Init yc profile with your account:
```
yc init
```

2. Now, Inside Yandex Cloud Console go ahead and find service account `terraform-deploy` with following permissions: `vpc.admin`, `compute.admin`, `load-balancer.admin`.

3. Create authorized key for your service account.
```
yc iam key create \
  --service-account-id <service_account_ID> \
  --description "<nickname>" \
  --output key.json
```
4. Create CLI profile to run operations on behalf of the service account:
   `yc config profile create <profile_name>`

5. Set the profile configuration:
```
yc config set service-account-key key.json 
yc config set cloud-id <cloud_ID> 
yc config set folder-id <folder_ID>
```

6. Export credentials to your environment:
```
source ./env_prepare.sh
```

> [!WARNING] 
> Tokens are alive for only 12 Hours!

## Deploying configuration

1. Clone current repo
2. Run `tofu init` to initialize yandex provider

> [!WARNING]
> VPN Needed, otherwise use Yandex Mirror

Create `.tofurc` file with following code: 
```HCL
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.opentofu.org/*/*"]
  }
  direct {
    exclude = ["registry.opentofu.org/*/*"]
  }
}
```
3. Test your terraform configuration with `tofu plan`
4. Apply your configuration to yandex cloud: `tofu apply`
5. Destroy everything in the cloud: `tofu destroy`

### TODO:
* switch in terraform configuration `yandex_compute_placement_group` to `yandex_compute_instance_group`
* write ansible playbooks to deploy kubernetes cluster via [kubespray](https://github.com/kubernetes-sigs/kubespray)
* switch port in healthchecks to k8s cluster's port
* add alerts? monitoring?
