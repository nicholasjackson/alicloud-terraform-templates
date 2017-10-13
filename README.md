# alicloud-terraform-templates
Repository for Terraform templates solutions based on Alibaba Cloud provider.

## Alicloud sample template solutions deployment
This section will describe how to use Terraform to deploy differents solutions.

### Pre-requisites

Software installed on your system: 
* [Terraform](https://www.terraform.io/) (>=0.10.7)
* [Aliyun Command Line Interface](https://www.alibabacloud.com/help/doc-detail/27260.htm)
* [Ossutil Command Line Toole] (https://www.alibabacloud.com/help/doc-detail/50452.htm)

On the one hand, we assume that you have already configured your aliyuncli with your Access Keys (https://github.com/aliyun/aliyun-cli#configure-the-aliyuncli). Also, please install individually Aliyun Python SDK for each service required, because some resource can to be setup only via through the cli.

On the other hand, you must export those environments variables otherwise you will have a prompt to enter the pieces of information :
```bash
export TF_VAR_access_key_id="XXXXXXXXXXXX"
export TF_VAR_access_key_secret="XXXXXXXXXXXX"
export TF_VAR_region="XX-XXXXX-X"
```

The following commands for the Ossutil show how you can obtain the command list and configure it in english:
```bash
ossutil -L en
ossutil config -L en
```

### Hosting

#### [Web Application Hosting](https://www.alibabacloud.com/solutions/hosting/Web-Application-Hosting)

Run the following commands to create the infrastructure :

```bash
cd hosting/web-application-hosting
terraform init
terraform plan|apply \
  --var 'solution_name=wah' \
  -var-file=parameters.tfvars \
  -state=terraform.tfstate
```

Then create the bucket with the Ossutil command line tool:
```bash
ossutil mb oss://wah-storage -e oss-[region].aliyuncs.com
```

#### [Accelerated Content Delivery](https://www.alibabacloud.com/solutions/hosting/Accelerated-Content-Delivery)

Run the following commands to create the infrastructure :

```bash
cd hosting/web-application-hosting
terraform init
terraform plan|apply \
  --var 'solution_name=acd' \
  -var-file=parameters.tfvars \
  -state=terraform.tfstate
```

Then create the bucket with the Ossutil command line tool:
```bash
ossutil mb oss://acd-storage -e oss-[region].aliyuncs.com
```

Finally create a CDN domain name pointing to the SLB public ip by following this [documentation](https://www.alibabacloud.com/help/doc-detail/27116.htm?spm=a3c0i.o27115en.b99.22.5851d5afSXJzo8)

