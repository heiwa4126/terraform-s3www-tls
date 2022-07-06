# terraform-s3www

Terraformでs3バケットをwww公開するサンプル。
s3にコンテンツも流し込む。


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

コンテンツ1個づつ指定しないといけないのかなぁ。
mimeも拡張子見てやってくれるといいんだけど。

コンテンツ部分のHCLを自動生成すればいいのかな。

[Using Terraform for S3 Storage with MIME Type Association | State Farm Engineering](https://engineering.statefarm.com/blog/terraform-s3-upload-with-mime/) にしたがってfor_eachとmimeで生成するようにした。
