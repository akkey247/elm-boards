# elm-boards

ElmとLaravelで作る掲示板システム

# 使い方

1. Laravelのモジュールをインストール

```bash
$ docker-compose run php-fpm ./composer.phar install
```

2. Docker起動

```
$ docker-compose up -d
```

3. php-fpmのサーバーに入る

```
$ docker-compose run --rm php-fpm php artisan migrate:refresh --seed --force
```

4. アクセス

http://localhost:8080/boards/
