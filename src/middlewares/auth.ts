

import * as jwt from "jsonwebtoken";
import {
    HASURA_JWT_SALT,
} from "../hasura/constants";
import {FastifyReply, FastifyRequest, HookHandlerDoneFunction} from "fastify";


export const authMiddleware = function(request: FastifyRequest, reply: FastifyReply, done: HookHandlerDoneFunction){
    const body: any = request.body;
    const query: any = request.query;

    switch(true) {
        case Boolean(body?.input.jwt):
        case Boolean(query.jwt):
            try {
                const decoded: any = jwt.verify(body?.input.jwt || query.jwt, HASURA_JWT_SALT)
                request.session = decoded;
                return done();
            } catch (e) {
                reply.status(498).send({
                    message: 'Provide valid JWT token to access'
                })
            }
            break;
        default:
            reply.status(401).send({
                message: 'Provide JWT token to access'
            })
            break;
    }
}