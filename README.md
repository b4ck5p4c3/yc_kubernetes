# Deploy K8s with terraform

### Requirements:
* OpenTofu
* Yandex Cloud CLI

### Yandex Cloud CLI installation
* MacOS:
  * Quick: `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`
  * Brew: `brew install yandex-cloud-cli`
* Linux:
  * Quick: `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`
  * Other: Seek your distro repos!
* Windows: 
  * Powershell: `iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')`

See: https://yandex.cloud/en-ru/docs/cli/quickstart#install

## Yandex Provider setup:

1. Now, Inside Yandex Cloud Console go ahead and create service account with following permissions: `admin`, `vpc_admin`, `compute.editor`.

2. Create authorized key for your service account.
```
yc iam key create \
  --service-account-id <service_account_ID> \
  --folder-name <name_of_folder_with_service_account> \
  --output key.json
```
3. Create CLI profile to run operations on behalf of the service account:
   `yc config profile create <profile_name>`

4. Set the profile configuration:
```
yc config set service-account-key key.json 
yc config set cloud-id <cloud_ID> 
yc config set folder-id <folder_ID>
```

5. Export credentials to your environment:
* Bash / Zsh:
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

* PowerShell:
```
$Env:YC_TOKEN=$(yc iam create-token) 
$Env:YC_CLOUD_ID=$(yc config get cloud-id) 
$Env:YC_FOLDER_ID=$(yc config get folder-id)
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
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```
3. Test your terraform configuration with `tofu plan`
4. Apply your configuration to yandex cloud: `tofu apply`
5. Destroy everything in the cloud: `tofu destroy`
