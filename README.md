# elm-boards

ElmとLaravelで作る掲示板システム

# 使い方

1. Laravelのモジュールをインストール

```
$ docker-compose run --rm php-fpm ./composer.phar install
```

3. マイグレーションを実行する

```
$ docker-compose run --rm php-fpm php artisan migrate:refresh --seed --force
```

2. コンテナ起動

```
$ docker-compose up -d
```

4. アクセス

コンテナ起動後アクセスできるようになるまで少し時間がかかるのでちょっと待ってからアクセスする。

http://localhost:8080/boards/

[補足]
コンテナの起動状況を確認するコマンド

```
$ docker ps -a
```

起動中のコンテナを全部停止するコマンド

```
$ docker stop $(docker ps -q -a)
```

停止中のコンテナを全部削除するコマンド

```
$ docker rm $(docker ps -q -a)
```
