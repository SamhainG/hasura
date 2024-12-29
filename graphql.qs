mutation AddUser($email: String!,$password:String!) {
  AddUser(email: $email, password: $password) {
    user_id
  }
}
{
  "email": "testauthor@gmail.com",
  "password": "privet"
}

=============================================

mutation AddAuthorByToken($user_id: uuid!, $role: String!, $token: String!) {
  AddAuthorByToken(role: $role, token: $token, user_id: $user_id) {
    role,
    user_id
  }
}
#with admin's token
{
  "user_id":"4048446f-b1f3-461d-9b31-7e1a9278b120",
  "role": "author",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiM2M2ZDU2NTYtNDdkNi00MjAxLTgwZGYtOTM3NzdjYzVlOGQ4Iiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1MDQwMzgxLCJleHAiOjE3MzUxMjY3ODF9.CjiwqfjSFGl5kPJtlCdHhA_xvB8-n-wtiVKVJKKttUI"
}

=============================================
query MyQuery($email: String!, $password: String!) {
  SignIn(email: $email, password: $password) {
    jwt
  }
}
{
  "email": "testauthor@gmail.com",
  "password": "privet"
}
# admin's jwt: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiM2M2ZDU2NTYtNDdkNi00MjAxLTgwZGYtOTM3NzdjYzVlOGQ4Iiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1MDQwMzgxLCJleHAiOjE3MzUxMjY3ODF9.CjiwqfjSFGl5kPJtlCdHhA_xvB8-n-wtiVKVJKKttUI
# author's jwt: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTgxMTVmOTktNzJmYS00YWQ4LWEyYjEtZGJjNmQ5MTIwZjRlIiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTAzOTc1NCwiZXhwIjoxNzM1MTI2MTU0fQ.FwTMM_sh5W1IlTc7pwkv2A5jtb2D1kffSuRTal4aacM
# one more author's jwt: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDA0ODQ0NmYtYjFmMy00NjFkLTliMzEtN2UxYTkyNzhiMTIwIiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTA0NDkxNiwiZXhwIjoxNzM1MTMxMzE2fQ.qtHypuG_xPGXhOXIHSeu_LJp3WKu8JWCJfOibqcyl2g

=============================================
mutation AddImageByToken($token:String!,$base64:String!) {
  AddImageByToken(token: $token, base64: $base64){
    image_id
  }
}

{
  "base64": "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",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTgxMTVmOTktNzJmYS00YWQ4LWEyYjEtZGJjNmQ5MTIwZjRlIiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNDk2MDA0MiwiZXhwIjoxNzM1MDQ2NDQyfQ.zj7NTRYsR8qW23mCGR-19zolrTH1t0lQUto8dNPbJqc"
}



=============================================



mutation InsertAuthor ($email:String,$role:String) {
  insert_Test_authors_one(object: {
    email: $email,
    role: $role
  }) {
    author_id,
    role
  }
}


================================================
jwt: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTE1Yzc3ODEtYWEzNS00Y2QyLWI3ZjUtOTcwMzA5ZGI4YWYzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM0OTQzNDAzLCJleHAiOjE3MzUwMjk4MDN9.ZZ2oYLvk_qNAqmcV-a5DwbJ36kGq6Y_RZzly4bLSE80

query MyQuery($email: String!, $password: String!) {
  SignIn(email: $email, password: $password) {
    jwt
  }
}

{
  "email": "testauthor2@gmail.com",
  "password": "privet"
}
testauthor2@gmail.com
====================================


mutation AddCollectionByToken($token: String!, $collection_name: String!) {
  AddCollection(collection_name: $collection_name, token: $token){
    collection_id
  }
}

{
  "collection_name": "testCollection5",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTE1Yzc3ODEtYWEzNS00Y2QyLWI3ZjUtOTcwMzA5ZGI4YWYzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM0OTQzNDAzLCJleHAiOjE3MzUwMjk4MDN9.ZZ2oYLvk_qNAqmcV-a5DwbJ36kGq6Y_RZzly4bLSE80"
}

======================================
mutation AddAuthorByToken($role:String!,$token:String!,$user_id:uuid!) {
  AddAuthorByToken(role: $role, token: $token, user_id: $user_id){
    role,
    user_id
  }
}
{
  "user_id": "2d8529a8-3ef5-4191-84ce-fb6a996352b9",
  "role": "author",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTE1Yzc3ODEtYWEzNS00Y2QyLWI3ZjUtOTcwMzA5ZGI4YWYzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM0OTQzNDAzLCJleHAiOjE3MzUwMjk4MDN9.ZZ2oYLvk_qNAqmcV-a5DwbJ36kGq6Y_RZzly4bLSE80"
}

==========================================

mutation AddAuthorToCollectionByToken($user_id: uuid!, $collection_id: uuid!) {
  insert_collections_vs_authors_one(object: {
    user_id: $user_id,
    collection_id: $collection_id
  }) {
    collection_id,
    user_id,
  }
}


mutation AddAuthorToCollectionByToken($collection_id: uuid!, $token: String!, $user_id: uuid!) {
  AddAuthorToCollectionByToken(collection_id: $collection_id, token: $token, user_id: $user_id){
    collection_id,
    user_id
  }
}
{
  "collection_id": "97559eab-17ff-4537-bf83-478702811dfe",
  "user_id": "915c7781-aa35-4cd2-b7f5-970309db8af3",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTE1Yzc3ODEtYWEzNS00Y2QyLWI3ZjUtOTcwMzA5ZGI4YWYzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM0OTQzNDAzLCJleHAiOjE3MzUwMjk4MDN9.ZZ2oYLvk_qNAqmcV-a5DwbJ36kGq6Y_RZzly4bLSE80"
}

==================================================
mutation MyMutation($image_id: uuid!, $tag_name: String!, $token: String!) {
  AddTagToImageByToken(tag_name: $tag_name, image_id: $image_id, token: $token) {
    image_id,
    tag_id
  }
}
{
  "tag_name" : "super new tag",
  "image_id": "4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTgxMTVmOTktNzJmYS00YWQ4LWEyYjEtZGJjNmQ5MTIwZjRlIiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNDk2MDA0MiwiZXhwIjoxNzM1MDQ2NDQyfQ.zj7NTRYsR8qW23mCGR-19zolrTH1t0lQUto8dNPbJqc"
}


===================================================


mutation AddImageVsCollectionRelationMutationByToken($collection_id: uuid!, $image_id: uuid!, $token: String!) {
  AddImageVsCollectionRelationMutationByToken(collection_id: $collection_id, image_id: $image_id, token: $token) {
    collection_id,
    image_id
  }
}

mutation AddImageVsCollectionRelationMutation($collection_id:uuid!, $image_id:uuid!) {
  insert_collections_vs_images_one(object: {
    collection_id: $collection_id,
    image_id:$image_id
  }) {
    collection_id,
    image_id,
  }
}

{
  "image_id": "4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc",
  "collection_id": "97559eab-17ff-4537-bf83-478702811dfe"
}

{
  "image_id": "4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc",
  "collection_id": "97559eab-17ff-4537-bf83-478702811dfe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTgxMTVmOTktNzJmYS00YWQ4LWEyYjEtZGJjNmQ5MTIwZjRlIiwicm9sZSI6ImF1dGhvciIsImlhdCI6MTczNTAzOTc1NCwiZXhwIjoxNzM1MTI2MTU0fQ.FwTMM_sh5W1IlTc7pwkv2A5jtb2D1kffSuRTal4aacM"
}


=======================

query ImagesForPublic($image_id: uuid, $status: String, $url: String, $user_id: uuid) {
  ImagesForPublic(image_id: $image_id, status: $status, url: $url, user_id: $user_id){
    image_id,
    status,
    url,
    user_id
  }
}

query ImagesForPublic($image_id: uuid, $status: String, $url: String, $user_id: uuid) {
  images(where: {
    user_id: {
      _eq: $user_id
    }
  }){
    image_id
  }
}

{"user_id": "ed615421-4316-45d4-8c95-0f11d6f31539"}