// Import the framework and instantiate it
import Fastify, {FastifyReply, FastifyRequest} from 'fastify'
import {SigninController} from "./controllers/signin";
import {UsersController} from "./controllers/users"
import {RolesController} from "./controllers/roles";
import {CollectionsController} from "./controllers/collections";
import {ImagesController} from './controllers/images';
import {TagsController} from "./controllers/tags";
import {authMiddleware} from './middlewares/auth';

const signinController = new SigninController();
const userController = new UsersController();
const rolesController = new RolesController();
const collectionsController = new CollectionsController();
const imagesController = new ImagesController();
const tagsController = new TagsController();

declare module 'fastify' {
    interface FastifyRequest {
        session: {
            user_id: string | null;
            role: string | null;
        } | null;
    }
}


let fastify = Fastify({
    logger: true
})


fastify.decorateRequest('session', null);
fastify.post('/signin', signinController.postAction);
fastify.post('/users', userController.postAction);
fastify.post('/users/roles', {
    preHandler: [authMiddleware]
}, rolesController.postAction);
fastify.post('/collections', {
    preHandler: [authMiddleware]
}, collectionsController.postAction);
fastify.put('/collections/:entity', {
    preHandler: [authMiddleware]
}, collectionsController.putAction);
fastify.post('/public/images', imagesController.getAction);
fastify.post('/images', {
    preHandler: [authMiddleware]
}, imagesController.postAction);
fastify.put('/images', {
    preHandler: [authMiddleware]
}, imagesController.putAction);
fastify.post('/images/tags', {
    preHandler: [authMiddleware]
}, tagsController.postAction);


// Run the server!
try {
    fastify.listen({port: 3000, host: process.env.HOSTNAME})
        .then(() => {
            console.info('server started successfully');
        }).catch((err) => {
        console.error('21: some error happened', err)
    })
} catch (err) {
    fastify.log.error(err)
    process.exit(1)
}