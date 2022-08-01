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
cp main_override.tf- main_override.tf
vim main_override.tf  # backend情報などをお好みに合わせて修正
```

で

```bash
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

CloudFrontごしではサブディレクトリのデフォルトドキュメントが使えないことに注意。

このへん参考
- [AWS CloudFront + S3による静的サイト配信時のインデックスドキュメントについて | 麦茶派エンジニア](https://crimsonality.net/aws/about-cloudfront-s3-index-document/)
- [CloudFrontとS3で作成する静的サイト構成の私的まとめ | DevelopersIO](https://dev.classmethod.jp/articles/s3-cloudfront-static-site-design-patterns-2022/)

OAIでCloudFront限定にして、
S3 WWWにアクセスすればまあいいわけだ。
