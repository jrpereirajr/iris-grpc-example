"""
The Python implementation of the GRPC helloworld.Greeter server.
Adapted from:
    - https://github.com/grpc/grpc/blob/master/examples/python/helloworld/async_greeter_server.py
    - https://github.com/grpc/grpc/blob/master/examples/python/hellostreamingworld/async_greeter_server.py
    - https://groups.google.com/g/grpc-io/c/6Yi_oIQsh3w
"""

from concurrent import futures
import logging
import signal
from typing import Any
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

import grpc
from helloworld_pb2 import HelloRequest, HelloReply
from helloworld_pb2_grpc import MultiGreeterServicer, add_MultiGreeterServicer_to_server

import iris

NUMBER_OF_REPLY = 10

parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("-p", "--port", default="50051", help="Server port")
args = vars(parser.parse_args())

class Greeter(MultiGreeterServicer):

    def SayHello(self, request: HelloRequest, context) -> HelloReply:
        logging.info("Serving SayHello request %s", request)
        obj = iris.cls("dc.jrpereira.gRPC.HelloWorldServer")._New()
        # hook to your ObjectScript code
        return obj.SayHelloObjectScript(request)

    def SayHelloStream(self, request: HelloRequest, context: grpc.aio.ServicerContext) -> HelloReply:
        logging.info("Serving SayHelloStream request %s", request)
        obj = iris.cls("dc.jrpereira.gRPC.HelloWorldServer")._New()
        n = request.num_greetings
        if n == 0:
            n = NUMBER_OF_REPLY
        for i in range(n):
            # hook to your ObjectScript code
            yield obj.SayHelloObjectScript(request)

def get_server():
    port = args["port"]
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    add_MultiGreeterServicer_to_server(Greeter(), server)
    listen_addr = f"[::]:{port}"
    server.add_insecure_port(f"[::]:{port}")
    logging.info("Starting server on %s", listen_addr)
    return server

def handle_sigterm(*_: Any) -> None :
    """Shutdown gracefully."""
    done_event = server.stop(None)
    done_event.wait(None)
    print('Stop complete.')

logging.basicConfig(level=logging.INFO)

server = get_server()
server.start()

# https://groups.google.com/g/grpc-io/c/6Yi_oIQsh3w
signal.signal(signal.SIGTERM, handle_sigterm)

server.wait_for_termination()
