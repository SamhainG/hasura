import {IPostAction} from "../interfaces/IPostAction";
import {FastifyReply, FastifyRequest} from "fastify";
import * as jwt from "jsonwebtoken";
import {
    HASURA_SIGN_IN_QUERY,
} from "../hasura/queries";
import {
    HASURA_PASSWORD_SALT,
    HASURA_JWT_SALT,
    HASURA_JWT_EXPIRE_SEC,
} from "../hasura/constants";
import {createHash} from "crypto";
import {HasuraFetch} from "../services/hasura/fetch";


export class SigninController implements IPostAction {
    async postAction(request: FastifyRequest, reply: FastifyReply): Promise<any> {

        const body: any = request?.body;

        const {input: {email, password}}: { input: { email: string, password: string } } = body;
        if (email.length > 0 && password.length > 0) {
            const fetchResponse = await new HasuraFetch(
                request.session,
                {
                    query: HASURA_SIGN_IN_QUERY,
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
                jwt: jwt.sign(
                    {
                        user_id: data.users[0].user_id,
                        role: data.users[0].users_vs_roles[0].role
                    },
                    HASURA_JWT_SALT,
                    {
                        expiresIn: HASURA_JWT_EXPIRE_SEC
                    }
                )
            })

        } else {
            return reply.status(400).send({
                message: 'invalid email or password'
            });
        }

    }
}