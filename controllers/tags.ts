import {IPostAction} from "../interfaces/IPostAction";
import {FastifyReply, FastifyRequest} from "fastify";
import {HASURA_ROLE_AUTHOR} from "../hasura/constants";
import {HasuraFetch} from "../services/hasura/fetch";
import {HASURA_ADD_TAG_MUTATION, HASURA_ADD_TAG_VS_IMAGE_RELATION_MUTATION} from "../hasura/queries";

export class TagsController implements IPostAction {
    async postAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {
        if (request.session?.role === HASURA_ROLE_AUTHOR) {
            const body: any = request.body;
            const fetchResponse = await new HasuraFetch(
                request.session,
                {
                    query: HASURA_ADD_TAG_MUTATION,
                    variables: {tag_name: body.input.tag_name}
                },
                'POST'
            ).send()
            const {data, errors} = await fetchResponse.json();
            if (errors) {
                return reply.status(400).send(errors[0])
            } else {
                const relationResponse = await new HasuraFetch(
                    request.session,
                    {
                        query: HASURA_ADD_TAG_VS_IMAGE_RELATION_MUTATION,
                        variables: {tag_id: data.insert_tags_one.tag_id, image_id: body.input.image_id}
                    },
                    'POST'
                ).send()
                let {data: dataRel, errors} = await relationResponse.json();

                if (errors) {
                    return reply.status(400).send(errors[0])
                }

                return reply.send({
                    ...dataRel.insert_tags_vs_images_one
                })

            }

        } else {
            reply.status(401).send({
                message: 'You are not allowed'
            });
        }
    }
}