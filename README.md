# terraform-s3www-tsl

「Terraformでs3バケットをwww公開するサンプル terraform-s3www」のフォークで
aws_acm_certificate を使って https の独自ドメインで公開するサンプル。

# 前提

Route 53でホストゾーンを登録していること


# deploy

AWSアカウントは
環境変数で設定するか、
それともdefaultプロファイルをそのまま使うか
してください。

[provider "aws" の profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#profile)
などを書いてもいいです。

```bash
cp terraform.tfvars- terraform.tfvars
vim terraform.tfvars  # お好みに合わせて修正
terraform init
terraform apply
```

テストは
```bash
./curl-test.sh
```
またはoutputのs3wwwurlのURLにブラウザでアクセス


# メモ

[Using Terraform for S3 Storage with MIME Type Association | State Farm Engineering](https://engineering.statefarm.com/blog/terraform-s3-upload-with-mime/) にしたがって
ディレクトリまるごとfor_eachとmimeでs3にあげるようにした。
`terraform state list` でどんな感じかわかると思う。
