import {FastifyReply, FastifyRequest} from "fastify";

export interface IPostAction {
    postAction(request: FastifyRequest, reply: FastifyReply): Promise<any>
}