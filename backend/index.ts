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

contract.transfer("0x57C641e614fB9Ca266C8a8e0Ab4285d2fAd74D63", 1)