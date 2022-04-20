"""
The Python implementation of the GRPC helloworld.Greeter client.
Adapted from:
    - https://github.com/grpc/grpc/blob/master/examples/python/helloworld/async_greeter_client.py
    - https://github.com/grpc/grpc/blob/master/examples/python/hellostreamingworld/async_greeter_client.py
"""

import logging
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

import grpc
from helloworld_pb2 import HelloRequest
from helloworld_pb2_grpc import MultiGreeterStub

parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("-p", "--port", default="50051", help="Server port")
args = vars(parser.parse_args())

def run() -> None:
    port = args["port"]
    channel = grpc.insecure_channel(f'localhost:{port}')
    stub = MultiGreeterStub(channel)

    response = stub.SayHello(HelloRequest(name='you'))
    print("Greeter client received: " + response.message)
    
    for response in stub.SayHelloStream(HelloRequest(name="you")):
        print("Greeter client received from stream: " + response.message)

logging.basicConfig(level=logging.INFO)
run()
