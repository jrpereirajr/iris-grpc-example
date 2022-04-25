Class dc.jrpereira.gRPC.HelloWorldClient Extends %RegisteredObject
{

Method ExecutePython() [ Language = python ]
{
    import sys
    sys.path.append('/usr/irissys/mgr/python/grpc-test/')

    import grpc
    from helloworld_pb2 import HelloRequest
    from helloworld_pb2_grpc import MultiGreeterStub
    
    channel = grpc.insecure_channel('localhost:50051')
    stub = MultiGreeterStub(channel)

    response = stub.SayHello(HelloRequest(name='you'))
    print("Greeter client received: " + response.message)
    
    for response in stub.SayHelloStream(HelloRequest(name="you")):
        print("Greeter client received from stream: " + response.message)
}

}
