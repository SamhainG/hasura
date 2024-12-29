import {FastifyReply, FastifyRequest} from "fastify";

export interface IGetAction {
    getAction(request: FastifyRequest, reply: FastifyReply): Promise<any>
}