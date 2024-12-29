export const HASURA_ADD_USER_MUTATION = `
mutation AddUser ($email: String!, $password:String!) {
  insert_users_one(object: {
    email:$email,
    password:$password,
  }) {
    user_id
  }
}
`;
export const HASURA_ADD_USER_ROLE_MUTATION = `
mutation AddRole ($user_id:uuid, $role:String) {
  insert_users_vs_roles_one(object: {role: $role, user_id: $user_id}) {
    role
    user_id
  }
}
`;

export const HASURA_SIGN_IN_QUERY = `
query SignIn($email:String!, $password: String!) {
  users(limit: 1, where: {_and: {email: {_eq: $email}, password: {_eq: $password}}}) {
    user_id
    users_vs_roles {
      role
    }
  }
}
`;

export const HASURA_ADD_COLLECTION_MUTATION = `
mutation AddCollectionByToken ($collection_name:String!) {
  insert_collections_one(object: {
    collection_name: $collection_name
  }) {
    collection_id
  }
}
`;

export const HASURA_ADD_AUTHOR_TO_COLLECTION_MUTATION = `
mutation AddAuthorToCollectionByToken($user_id: uuid!, $collection_id: uuid!) {
  insert_collections_vs_authors_one(object: {
    user_id: $user_id,
    collection_id: $collection_id
  }) {
    collection_id,
    user_id,
  }
}
`;

export const HASURA_ADD_IMAGE_MUTATION = `
mutation AddImageByToken($url:String!,$user_id:uuid!) {
  insert_images_one(object: {
    url: $url,
    user_id: $user_id
  }) {
    image_id,
    url
  }
}
`;

export const HASURA_UPDATE_IMAGE_STATUS_MUTATION = `
mutation UpdateImageStatusByToken($image_id: uuid!, $status: String!) {
  update_images_by_pk(_set: {status:$status}, pk_columns: {
    image_id:$image_id
  }){
    image_id,
    status
  }
}
`;

export const HASURA_ADD_TAG_MUTATION = `
mutation AddTagMutation($tag_name: String!) {
  insert_tags_one(object: {
    name: $tag_name
  }) {
    tag_id
  }
}
`;

export const HASURA_ADD_TAG_VS_IMAGE_RELATION_MUTATION = `
mutation AddTagVsImageRelation ($tag_id: uuid!, $image_id: uuid!) {
  insert_tags_vs_images_one(object: {
    image_id: $image_id,
    tag_id: $tag_id
  }) {
    image_id,
    tag_id
  }
}
`;

export const HASURA_ADD_IMAGE_VS_COLLECTION_RELATION_MUTATION = `
mutation AddImageVsCollectionRelationMutation($collection_id:uuid!, $image_id:uuid!) {
  insert_collections_vs_images_one(object: {
    collection_id: $collection_id,
    image_id:$image_id
  }) {
    collection_id,
    image_id,
  }
}
`;

export const HASURA_IMAGES_PUBLIC_QUERY = `
query ImagesForPublic($image_id: uuid, $status: String, $url: String, $user_id: uuid) {
  images(where: {
    _and: {{where}}
  }){
    image_id,
    status,
    url,
    user_id
  }
}
`;