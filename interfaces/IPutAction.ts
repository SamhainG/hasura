import {FastifyReply, FastifyRequest} from "fastify";

export interface IPutAction {
    putAction(request: FastifyRequest, reply: FastifyReply): Promise<any>
}