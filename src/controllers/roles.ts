import {IPostAction} from "../interfaces/IPostAction";

import {
    HASURA_ROLE_AUTHOR,
    HASURA_ROLE_ADMIN,
} from '../hasura/constants';
import {
    HASURA_ADD_USER_ROLE_MUTATION
} from '../hasura/queries';
import {FastifyReply, FastifyRequest} from "fastify";
import {HasuraFetch} from "../services/hasura/fetch";


export class RolesController implements IPostAction {
    async postAction(request: FastifyRequest, reply: FastifyReply) {
        const body: any = request?.body;
        const {input: {user_id, role}}: { input: { user_id: string, role: string } } = body;
        if (request.session?.role === HASURA_ROLE_ADMIN) {
            if (user_id.length > 0 && role.length > 0) {
                if ([HASURA_ROLE_ADMIN, HASURA_ROLE_AUTHOR].indexOf(role) !== -1) {
                    const fetchResponse = await new HasuraFetch(
                        request.session,
                        {
                            query: HASURA_ADD_USER_ROLE_MUTATION,
                            variables: {user_id, role}
                        },
                        'POST'
                    ).send()
                    const {data, errors} = await fetchResponse.json();

                    if (errors) {
                        return reply.status(400).send(errors[0])
                    }

                    return reply.send({
                        ...data.insert_users_vs_roles_one
                    })

                } else {
                    return reply.status(400).send({
                        message: 'invalid role passed'
                    })
                }
            } else {
                return reply.status(400).send({
                    message: 'required params are missed'
                })
            }
        } else {
            reply.status(401).send({
                message: 'You are not allowed'
            });
        }

    }
}