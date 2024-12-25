# hasura
# Змінні оточення

Вони всі зберігаються в ```.env``` файлі у корню цього проекта. 
Більшість із них була запозичена із офіційного прикладу docker-compose.yml.
Але деякі є специфічними для даного проекту: ```HASURA_GRAPHQL_ACTION_BASE_URL, HASURA_GRAPHQL_HOST, HASURA_GRAPHQL_PORT, IMGUR_CLIENT_ID```

# Метаданні Hasura

Додав до репозиторію у файл ```hasura_metadata_2024_12_25_01_46_19_829.json```

# Дамп бази PostgreSQL

Додав до репозиторію у файл ```postgresql.sql``` 

# Запуск за допомогою docker compose

```docker compose up -d```

# Структура проекту

Я шукав якийсь шаблон проекту Hasura, але не знайшов.

Тому поскладав все (бекенд сервіс для Hasura Actions) в корені проекта.

Я не мав жодного комерційного досвіду із Hasura чи Fastify, але усе інше окремо мені було відомо, інакше це мабуть зайняло трохи більше часу - я був оптимістом, коли оцінював це.

# Dev режим

В ```docker-compose.yml``` треба розкоментити:

```
    #entrypoint: 'npm run start-dev'
    #volumes:
    #  - ./controllers:/app/controllers
    #  - ./middlewares:/app/middlewares
    #  - ./interfaces:/app/interfaces
    #  - ./hasura:/app/hasura
    #  - ./services:/app/services
    #  - ./index.ts:/app/index.ts
```

# Створення першого admin користувача

Його токен ми будем потім використовувати, щоб перевіряти права доступа.

Заходимо у http://localhost:8080/console/api/api-explorer і виконуємо запит із параметрами:

```graphql
mutation AddUser($email: String!,$password:String!) {
  AddUser(email: $email, password: $password) {
    user_id
  }
}
```
```json
{
  "email": "admin@admin.com",
  "password": "admin"
}
```

Отримуємо відповідь типу:

```json
{
  "data": {
    "AddUser": {
      "user_id": "c26b836e-5dc8-4f73-8a50-f2e764b500a4"
    }
  }
}
```

Першому admin користувачу надаєм права міграцією (наступним вже можна буде через action-backend це робити):

```graphql
mutation AddFirstAdminMigration($role:String!, $user_id: uuid!) {
  insert_users_vs_roles_one(object: {
    role: $role,
    user_id: $user_id,
  }) {
    role,
    user_id
  }
}
```
```json
{
  "role": "admin",
  "user_id": "c26b836e-5dc8-4f73-8a50-f2e764b500a4"
}
```

У відповідь маємо отримати щось на зразок:

```json
{
  "data": {
    "insert_users_vs_roles_one": {
      "role": "admin",
      "user_id": "c26b836e-5dc8-4f73-8a50-f2e764b500a4"
    }
  }
}
```
## Отримання jwt для першого admin-користувача

```graphql
query SignInQuery($email: String!, $password: String!) {
  SignIn(email: $email, password: $password) {
    jwt
  }
}
```
```json
{
  "email": "admin@admin.com",
  "password": "admin"
}
```

У відповідь маємо отримати щось типу цього:

```json
{
  "data": {
    "SignIn": {
      "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYzI2YjgzNmUtNWRjOC00ZjczLThhNTAtZjJlNzY0YjUwMGE0Iiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1MDQ1OTE5LCJleHAiOjE3MzUxMzIzMTl9.UVPYI3XKPaMekCocfgwgHTlE8vIr0ZSacB6hTE-9jSo"
    }
  }
}
```

Тепер треба зберігти собі цей токен, бо він знадобиться.

# Доступні для admin'а методи

## Додавання нової колекції

Використовуєм вищезгаданий токен для цього запиту:

```graphql
mutation AddCollectionByToken($token: String!, $collection_name: String!) {
  AddCollection(collection_name: $collection_name, token: $token){
    collection_id
  }
}
```
```json
{
  "collection_name": "first collection",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYzI2YjgzNmUtNWRjOC00ZjczLThhNTAtZjJlNzY0YjUwMGE0Iiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1MDQ1OTE5LCJleHAiOjE3MzUxMzIzMTl9.UVPYI3XKPaMekCocfgwgHTlE8vIr0ZSacB6hTE-9jSo"
}
```

У Відповідь маємо отримати щось типу такого:

```json
{
  "data": {
    "AddCollection": {
      "collection_id": "111e3a90-6cc6-4c8a-87c8-9df1126a8574"
    }
  }
}
```

## Додавання автора

Для цього запиту нам знадобиться uuid вже існуючого користувача, для цього потрібно його створити використовуючи вже згаданий метод:

```graphql
mutation AddUser($email: String!,$password:String!) {
  AddUser(email: $email, password: $password) {
    user_id
  }
}
```
```json
{
  "email": "author1@author.com",
  "password": "author1"
}
```
У відповіді маємо отримати щось типу цього:

```json
{
  "data": {
    "AddUser": {
      "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
    }
  }
}
```

Використовуючи отриманий ```user_id``` ми можем надати йому права ```author```

```graphql
mutation AddAuthorByToken($role:String!,$token:String!,$user_id:uuid!) {
  AddAuthorByToken(role: $role, token: $token, user_id: $user_id){
    role,
    user_id
  }
}
```
```json
{
  "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539",
  "role": "author",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYzI2YjgzNmUtNWRjOC00ZjczLThhNTAtZjJlNzY0YjUwMGE0Iiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1MDQ1OTE5LCJleHAiOjE3MzUxMzIzMTl9.UVPYI3XKPaMekCocfgwgHTlE8vIr0ZSacB6hTE-9jSo"
}
```
Приклад відповіді:
```json
{
  "data": {
    "AddAuthorByToken": {
      "role": "author",
      "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
    }
  }
}
```

## Призначення авторів колекціям

Берем вже вищеотримані ```collection_id``` та ```user_id``` та передаєм їх у запиті:

```graphql
mutation AddAuthorToCollectionByToken($collection_id: uuid!, $token: String!, $user_id: uuid!) {
  AddAuthorToCollectionByToken(collection_id: $collection_id, token: $token, user_id: $user_id){
    collection_id,
    user_id
  }
}
```
```json
{
  "collection_id": "111e3a90-6cc6-4c8a-87c8-9df1126a8574",
  "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYzI2YjgzNmUtNWRjOC00ZjczLThhNTAtZjJlNzY0YjUwMGE0Iiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1MDQ1OTE5LCJleHAiOjE3MzUxMzIzMTl9.UVPYI3XKPaMekCocfgwgHTlE8vIr0ZSacB6hTE-9jSo"
}
```
Відповідь:
```json
{
  "data": {
    "AddAuthorToCollectionByToken": {
      "collection_id": "111e3a90-6cc6-4c8a-87c8-9df1126a8574",
      "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
    }
  }
}
```

Таким чином імплементований пункт завдання:

```Admin: может добавлять новые коллекции и новых авторов, а так же назначать авторов для коллекций```

# Доступні для author'а методи

## Додавання нових картинок

Перед тим як додавати картинки нам треба отримати токен доступу для author'а

```graphql
query SignInQuery($email: String!, $password: String!) {
  SignIn(email: $email, password: $password) {
    jwt
  }
}
```
```json
{
  "email": "author1@author.com",
  "password": "author1"
}
```
Результат:
```json
{
  "data": {
    "SignIn": {
      "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWQ2MTU0MjEtNDMxNi00NWQ0LThjOTUtMGYxMWQ2ZjMxNTM5Iiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTA0ODU1MiwiZXhwIjoxNzM1MTM0OTUyfQ.RAx_LMmsOj0XgWnp4-oqwEFRc_9xIaxptPWO3rmjKDE"
    }
  }
}
```

Для додавання картиники потрібне або посилання або base64 файла і токен 

```graphql
mutation AddImageByToken($token:String!,$base64:String!) {
  AddImageByToken(token: $token, base64: $base64){
    image_id
    url
  }
}
```

```json
{
  "base64": "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",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWQ2MTU0MjEtNDMxNi00NWQ0LThjOTUtMGYxMWQ2ZjMxNTM5Iiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTA0ODU1MiwiZXhwIjoxNzM1MTM0OTUyfQ.RAx_LMmsOj0XgWnp4-oqwEFRc_9xIaxptPWO3rmjKDE"
}
```

Результа матиме наступний вигляд:

```json
{
  "data": {
    "AddImageByToken": {
      "image_id": "d5394aea-167d-4fcc-9028-b46368c0f211",
      "url": "https://i.imgur.com/occOO49.png"
    }
  }
}
```

Або, якщо вказати своє посилання:

```graphql
mutation AddImageByToken($token:String!,$link:String!) {
  AddImageByToken(token: $token, link: $link){
    image_id
    url
  }
}
```
```json
{
  "link": "https://my.custom.link/blabla.png",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWQ2MTU0MjEtNDMxNi00NWQ0LThjOTUtMGYxMWQ2ZjMxNTM5Iiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTA0ODU1MiwiZXhwIjoxNzM1MTM0OTUyfQ.RAx_LMmsOj0XgWnp4-oqwEFRc_9xIaxptPWO3rmjKDE"
}
```

Результат матиме наступний вигляд:

```json
{
  "data": {
    "AddImageByToken": {
      "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
      "url": "https://my.custom.link/blabla.png"
    }
  }
}
```

## Зміна статусу картинок

```graphql
mutation UpdateImageStatusByToken($image_id: uuid!, $status: String!, $token:String!) {
  UpdateImageStatusByToken(image_id: $image_id, status: $status, token: $token) {
    image_id,
    status,
  }
}
```
```json
{
  "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWQ2MTU0MjEtNDMxNi00NWQ0LThjOTUtMGYxMWQ2ZjMxNTM5Iiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTA0ODU1MiwiZXhwIjoxNzM1MTM0OTUyfQ.RAx_LMmsOj0XgWnp4-oqwEFRc_9xIaxptPWO3rmjKDE",
  "status": "checked"
}
```

Результат матиме вигляд:

```json
{
  "data": {
    "UpdateImageStatusByToken": {
      "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
      "status": "checked"
    }
  }
}
```

## Додавання тегів до картинок

```graphql
mutation AddTagToImageByToken($image_id: uuid!, $tag_name: String!, $token: String!) {
  AddTagToImageByToken(tag_name: $tag_name, image_id: $image_id, token: $token) {
    image_id,
    tag_id
  }
}
```
```json
{
  "tag_name" : "super new tag",
  "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWQ2MTU0MjEtNDMxNi00NWQ0LThjOTUtMGYxMWQ2ZjMxNTM5Iiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTA0ODU1MiwiZXhwIjoxNzM1MTM0OTUyfQ.RAx_LMmsOj0XgWnp4-oqwEFRc_9xIaxptPWO3rmjKDE"
}
```

Результат матиме наступний виглдя:
```json
{
  "data": {
    "AddTagToImageByToken": {
      "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
      "tag_id": "d8817196-0f10-4b32-9dbb-812786e7fba6"
    }
  }
}
```

# Доступні public методи

## Пошук картинок

```graphql
query ImagesForPublic($image_id: uuid, $status: String, $url: String, $user_id: uuid) {
  ImagesForPublic(image_id: $image_id, status: $status, url: $url, user_id: $user_id){
    image_id,
    status,
    url,
    user_id
  }
}
```

```json
{"status": "checked"}
```
Приклад відповіді:
```json
{
  "data": {
    "ImagesForPublic": [
      {
        "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
        "status": "checked",
        "url": "https://my.custom.link/blabla.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      }
    ]
  }
}
```

Аналогічним чином можна отримати дані по конкретній картинці, вказавши її ```image_id```:


# Задачі на проектування БД

## Показати автору картинки у правильному порядку

```Сделать запрос, который будет показывать автору в первую очередь его собственные картинки, потом картинки коллекций в которых он участвует, а потом уже все остальные картинки```

```sql
SELECT iii.image_id, iii.url, iii.created_at, iii.status, iii.user_id, 2 as prio
FROM public.images iii
UNION
SELECT i.image_id, i.url, i.created_at, i.status, i.user_id, 0 as prio
FROM public.images i
WHERE i.user_id={{user_id}}
UNION
SELECT ii.image_id, ii.url, ii.created_at, ii.status, ii.user_id, 1 as prio
FROM public.collections_vs_authors cva
INNER JOIN public.collections_vs_images cvi ON cva.collection_id=cvi.collection_id
INNER JOIN public.images ii ON ii.image_id=cvi.image_id
WHERE cva.user_id={{user_id}}
ORDER BY prio asc, created_at desc
```

```graphql
query ImagesForTheAuthorInCorrectOrder($user_id: uuid!) {
  ImagesForTheAuthorInCorrectOrder(args: {user_id: $user_id}) {
    image_id,
    created_at,
    status,
    url,
    user_id
  }
}
```

```json
{
  "user_id" : "ed615421-4316-45d4-8c95-0f11d6f31539"
}
```

Результат має приблизно такий вигляд:
```json
{
  "data": {
    "ImagesForTheAuthorInCorrectOrder": [
      {
        "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
        "created_at": "2024-12-24T14:03:43.072854+00:00",
        "status": "checked",
        "url": "https://my.custom.link/blabla.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      },
      {
        "image_id": "d5394aea-167d-4fcc-9028-b46368c0f211",
        "created_at": "2024-12-24T13:58:42.228154+00:00",
        "status": "unchecked",
        "url": "https://i.imgur.com/occOO49.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      },
      {
        "image_id": "be56f57c-94ac-4866-9c59-a311a98be04c",
        "created_at": "2024-12-24T13:57:07.839078+00:00",
        "status": "unchecked",
        "url": "https://i.imgur.com/vRBwV2I.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      },
      {
        "image_id": "38b16e72-5f61-4f85-8570-562236ab0fa7",
        "created_at": "2024-12-23T14:11:59.798894+00:00",
        "status": "checked2",
        "url": "testurl2",
        "user_id": "58115f99-72fa-4ad8-a2b1-dbc6d9120f4e"
      },
      {
        "image_id": "f8c0de83-3a9c-4a49-8823-1d3d64c7a631",
        "created_at": "2024-12-23T13:53:40.444636+00:00",
        "status": "unchecked",
        "url": "testurl",
        "user_id": "58115f99-72fa-4ad8-a2b1-dbc6d9120f4e"
      },
      {
        "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
        "created_at": "2024-12-24T14:03:43.072854+00:00",
        "status": "checked",
        "url": "https://my.custom.link/blabla.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      },
      {
        "image_id": "d5394aea-167d-4fcc-9028-b46368c0f211",
        "created_at": "2024-12-24T13:58:42.228154+00:00",
        "status": "unchecked",
        "url": "https://i.imgur.com/occOO49.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      },
      {
        "image_id": "be56f57c-94ac-4866-9c59-a311a98be04c",
        "created_at": "2024-12-24T13:57:07.839078+00:00",
        "status": "unchecked",
        "url": "https://i.imgur.com/vRBwV2I.png",
        "user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"
      },
      {
        "image_id": "4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc",
        "created_at": "2024-12-24T08:49:15.08051+00:00",
        "status": "unchecked",
        "url": "https://i.imgur.com/wXctydx.png",
        "user_id": "58115f99-72fa-4ad8-a2b1-dbc6d9120f4e"
      },
      {
        "image_id": "38b16e72-5f61-4f85-8570-562236ab0fa7",
        "created_at": "2024-12-23T14:11:59.798894+00:00",
        "status": "checked2",
        "url": "testurl2",
        "user_id": "58115f99-72fa-4ad8-a2b1-dbc6d9120f4e"
      },
      {
        "image_id": "f8c0de83-3a9c-4a49-8823-1d3d64c7a631",
        "created_at": "2024-12-23T13:53:40.444636+00:00",
        "status": "unchecked",
        "url": "testurl",
        "user_id": "58115f99-72fa-4ad8-a2b1-dbc6d9120f4e"
      },
      {
        "image_id": "983d3cb5-cc43-4209-a28a-7790cd147c8e",
        "created_at": "2024-12-23T13:43:16.871959+00:00",
        "status": "unchecked",
        "url": "test_url",
        "user_id": "58115f99-72fa-4ad8-a2b1-dbc6d9120f4e"
      }
    ]
  }
}
```
## Знайти картинки по тегу в одній або декількох колекціях

```sql
SELECT image_id, url, created_at, status, user_id, tags, collections FROM (
    SELECT i.image_id, i.url, i.created_at, i.status, i.user_id, string_agg(DISTINCT t.name, ',') as tags, string_agg(DISTINCT c.collection_name, ',') as collections
    FROM public.tags t
    INNER JOIN public.tags_vs_images tvi ON t.tag_id=tvi.tag_id
    INNER JOIN public.images i ON tvi.image_id=i.image_id
    LEFT JOIN public.collections_vs_images cvi ON i.image_id=cvi.image_id
    LEFT JOIN public.collections c ON cvi.collection_id=c.collection_id
    GROUP BY i.image_id
) tmp
WHERE lower(tags) similar to ('%' || {{search_tag}} || '%')
```

```graphql
query ImagesByTagsInCollections {
  ImagesByTagsInCollections( args: {
    search_tag: "test|super"
  }, where: {
    _or: [
      {
        collections: {
          _is_null:true
        }
      },
      {
        collections: {
          _similar: "%test%"
        }
      }
    ]
  }) {
    image_id,
    status,
    tags,
    collections,
    url
  }
}
```

Результат роботи має приблизно такий вигляд:

```json
{
  "data": {
    "ImagesByTagsInCollections": [
      {
        "image_id": "4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc",
        "status": "unchecked",
        "tags": "super new tag,testtag",
        "collections": "testCollection5",
        "url": "https://i.imgur.com/wXctydx.png"
      },
      {
        "image_id": "983d3cb5-cc43-4209-a28a-7790cd147c8e",
        "status": "unchecked",
        "tags": "super new tag",
        "collections": null,
        "url": "test_url"
      },
      {
        "image_id": "ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73",
        "status": "checked",
        "tags": "super new tag",
        "collections": null,
        "url": "https://my.custom.link/blabla.png"
      }
    ]
  }
}
```