import {imgur} from '../../../config/default';
import {ImgurClient} from 'imgur';

const client = new ImgurClient({clientId: imgur.clientId});

export class ImgurUpload {

    private contentBase64: string;
    private title: string;
    private description: string;

    constructor(contentBase64: string, title: string = 'hasura test project', description: string = 'hasura test project') {
        this.contentBase64 = contentBase64;
        this.title = title;
        this.description = description;
    }

    send() {
        return client.upload({
            image: this.contentBase64,
            type: "base64",
            title: this.title,
            description: this.description,
        })
    }
}