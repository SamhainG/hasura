import {IPostAction} from "../interfaces/IPostAction";
import {FastifyReply, FastifyRequest} from "fastify";
import {createHash} from 'crypto';
import {
    HASURA_ADD_USER_MUTATION,
} from '../hasura/queries';
import {
    HASURA_PASSWORD_SALT
} from '../hasura/constants';
import {HasuraFetch} from "../services/hasura/fetch";


export class UsersController implements IPostAction {
    async postAction(request: FastifyRequest, reply: FastifyReply) {
        const body: any = request?.body;
        const {input: {email, password}}: { input: { email: string, password: string } } = body;

        if (email.length > 0 && password.length > 0) {
            const fetchResponse = await new HasuraFetch(
                request.session,
                {
                    query: HASURA_ADD_USER_MUTATION,
                    variables: {
                        email,
                        password: createHash('md5').update(password + HASURA_PASSWORD_SALT).digest('hex')
                    }
                },
                'POST'
            ).send();
            const {data, errors} = await fetchResponse.json();

            if (errors) {
                return reply.status(400).send(errors[0])
            }

            return reply.send({
                ...data.insert_users_one
            })
        } else {
            return reply.status(400).send({
                message: 'required params are empty'
            })
        }


    }
}