import {hasura} from "../../../config/default";
import {HASURA_ROLE_PUBLIC} from '../../hasura/constants';

export class HasuraFetch {
    private session;
    private body;
    private method;

    constructor(session: any, body: any, method: string) {
        this.session = session;
        this.body = body;
        this.method = method;
    }

    send() {
        return fetch(
            `http://${hasura.host}:${hasura.port}/v1/graphql`,
            {
                method: this.method,
                body: JSON.stringify(this.body),
                headers: {
                    'X-Hasura-Role': this.session?.role || HASURA_ROLE_PUBLIC,
                    'X-Hasura-User-Id': this.session?.user_id || '',
                    'X-Hasura-Admin-Secret': hasura.headers["X-Hasura-Admin-Secret"] || '',
                }
            }
        )

    }
}