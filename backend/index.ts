import Fastify from 'fastify'
import * as contract from './scripts/contract'
require("dotenv").config();

const server = Fastify({
  logger: true
})

server.get('/', (request, reply) => {
  reply.send({ hello: 'world' })
})

server.listen({ port: 8080 }, (err, address) => {
  if (err) {
    console.error(err)
    process.exit(1)
  }
})
