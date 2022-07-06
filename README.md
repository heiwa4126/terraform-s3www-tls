# terraform-s3www

Terraformでs3バケットをwww公開するサンプル。
s3にコンテンツも流し込む。


# deploy

```bash
cp terraform.tfvars- terraform.tfvars
vim terraform.tfvars
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
