export const hasura = {
    host: process.env.HASURA_GRAPHQL_HOST,
    port: process.env.HASURA_GRAPHQL_PORT,
    headers: {
        'X-Hasura-Admin-Secret': process.env.HASURA_GRAPHQL_ADMIN_SECRET
    }
};
export const imgur = {
    clientId: process.env.IMGUR_CLIENT_ID
};