# terraform-s3www-tsl

「Terraformでs3バケットをwww公開するサンプル terraform-s3www」のフォークで
aws_acm_certificate を使って https の独自ドメインで公開するサンプル。

# 前提

Route 53でホストゾーンを登録していること。


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
かなり時間がかかります(5分ぐらい)。


テストは
```bash
./curl-test.sh
```
またはoutputのs3wwwurl_tsl のURLにブラウザでアクセス


# メモ

「certificateだけus-east-1」というAWSの仕様にもかかわらず
1回でデプロイできるTerraformはえらい。
