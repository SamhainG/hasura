import {IPostAction} from "../interfaces/IPostAction";

import {FastifyReply, FastifyRequest} from "fastify";
import {HASURA_ROLE_ADMIN, HASURA_ROLE_AUTHOR} from "../hasura/constants";
import {
    HASURA_ADD_COLLECTION_MUTATION,
    HASURA_ADD_AUTHOR_TO_COLLECTION_MUTATION,
    HASURA_ADD_IMAGE_VS_COLLECTION_RELATION_MUTATION
} from "../hasura/queries";
import {HasuraFetch} from '../services/hasura/fetch';
import {IPutAction} from "../interfaces/IPutAction";

export class CollectionsController implements IPostAction, IPutAction {
    async postAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {
        const body: any = request.body;
        if (request.session?.role === HASURA_ROLE_ADMIN) {
            const fetchResponse = await new HasuraFetch(
                request.session,
                {
                    query: HASURA_ADD_COLLECTION_MUTATION,
                    variables: {collection_name: body.input.collection_name}
                },
                'POST'
            ).send();
            const {data, errors} = await fetchResponse.json();

            if (errors) {
                return reply.status(400).send(errors[0])
            }

            return reply.send({
                ...data.insert_collections_one
            })

        } else {
            reply.status(401).send({
                message: 'You are not allowed'
            });
        }
    }

    async putAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {
        const params: any = request.params;
        const session: any = request.session;
        if ([HASURA_ROLE_ADMIN, HASURA_ROLE_AUTHOR].indexOf(session?.role) !== -1) {
            const body: any = request.body;
            let query: any = {}, responseParam: string = '';
            switch (params.entity) {
                case 'authors':
                    query = {
                        query: HASURA_ADD_AUTHOR_TO_COLLECTION_MUTATION,
                        variables: {
                            collection_id: body.input.collection_id,
                            user_id: body.input.user_id,
                        }
                    };
                    responseParam = "insert_collections_vs_authors_one";
                    break;
                case 'images':
                    query = {
                        query: HASURA_ADD_IMAGE_VS_COLLECTION_RELATION_MUTATION,
                        variables: {
                            image_id: body.input.image_id,
                            collection_id: body.input.collection_id,
                        }
                    };
                    responseParam = 'insert_collections_vs_images_one';
                    break;
                default:
                    return reply.status(400).send({message: 'Unsupported entity name'});

            }

            const fetchResponse = await new HasuraFetch(
                session,
                query,
                'POST'
            ).send();

            const {data, errors} = await fetchResponse.json();

            if (errors) {
                return reply.status(400).send(errors[0])
            }
            return reply.send({
                ...data[responseParam]
            })
        } else {
            reply.status(401).send({
                message: 'You are not allowed'
            });
        }
    }
}