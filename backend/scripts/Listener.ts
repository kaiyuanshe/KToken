import fastify from 'fastify';
require("dotenv").config();

const server = fastify();
const host: string = process.env.SERVER_ADDRESS!;
const port: number = parseInt(process.env.SERVER_PORT!);

server.get('/', async (request, _) => {
    console.log(request.query);
})

server.listen({ port: port, host: host }, (err) => {
    if (err) {
        console.error(err)
        process.exit(1)
    }
    console.log(`Server listening...`)
})