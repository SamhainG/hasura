import {IPostAction} from "../interfaces/IPostAction";
import {FastifyReply, FastifyRequest} from "fastify";
import {HASURA_ROLE_AUTHOR} from "../hasura/constants";
import {HasuraFetch} from "../services/hasura/fetch";
import {
    HASURA_ADD_IMAGE_MUTATION,
    HASURA_UPDATE_IMAGE_STATUS_MUTATION,
    HASURA_IMAGES_PUBLIC_QUERY,
} from "../hasura/queries";
import {IPutAction} from "../interfaces/IPutAction";
import {ImgurUpload} from "../services/imgur/upload";
import {IGetAction} from "../interfaces/IGetAction";


export class ImagesController implements IPostAction, IPutAction, IGetAction {
    async postAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {
        if (request.session?.role === HASURA_ROLE_AUTHOR) {
            const body: any = request.body;
            let link: string;
            if (body.input.link) {
                link = body.input.link;
            } else if (body.input.base64) {
                const imageData = await new ImgurUpload(body.input.base64)
                    .send();
                link = imageData.data.link;
            } else {
                return reply.status(400).send({
                    message: 'You must specify link or base64'
                })
            }

            if (link) {
                const fetchResponse = await new HasuraFetch(
                    request.session,
                    {
                        query: HASURA_ADD_IMAGE_MUTATION,
                        variables: {user_id: request.session.user_id, url: link}
                    },
                    'POST'
                ).send()
                const {data, errors} = await fetchResponse.json();

                if (errors) {
                    return reply.status(400).send(errors[0])
                }

                return reply.send({
                    ...data.insert_images_one
                })
            } else {
                return reply.status(400).send({
                    message: 'Imgur service didnt return the link to image. Try one more time'
                })
            }
        } else {
            reply.status(401).send({
                message: 'You are not allowed'
            });
        }
    }

    async putAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {
        if (request.session?.role === HASURA_ROLE_AUTHOR) {
            const body: any = request.body;
            const fetchResponse = await new HasuraFetch(
                request.session,
                {
                    query: HASURA_UPDATE_IMAGE_STATUS_MUTATION,
                    variables: {image_id: body.input.image_id, status: body.input.status}
                },
                'POST'
            ).send()
            const {data, errors} = await fetchResponse.json();

            if (errors) {
                return reply.status(400).send(errors[0])
            }

            return reply.send({
                ...data.update_images_by_pk
            })

        } else {
            reply.status(401).send({
                message: 'You are not allowed'
            });
        }
    }

    async getAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {
        const body: any = request.body;
        const variables = Object.keys(body.input).reduce((prev, curr, index) => {
            if (body.input[curr]) {
                return {[curr]: body.input[curr], ...prev}
            } else {
                return prev;
            }
        }, {})
        const query = HASURA_IMAGES_PUBLIC_QUERY.replace('{{where}}', JSON.stringify(Object.keys(body.input).map((value, index, array) => {
            if (body.input[value]) {
                return {[value]: {_eq: `$${value}`}}
            }
        }).filter(Boolean)).replaceAll('"', ''))
        const fetchResponse = await new HasuraFetch(
            request.session,
            {
                query,
                variables
            },
            'POST'
        ).send()
        const {data, errors} = await fetchResponse.json();

        if (errors) {
            return reply.status(400).send(errors[0])
        }
        return reply.send(data.images)


    }
}