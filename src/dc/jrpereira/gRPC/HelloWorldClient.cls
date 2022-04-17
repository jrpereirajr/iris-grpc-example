Class dc.jrpereira.gRPC.HelloWorldClient Extends %RegisteredObject
{

ClassMethod ExecutePython() [ Language = python ]
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
    
    stub = MultiGreeterStub(channel)
    for response in stub.SayHelloStream(HelloRequest(name="you")):
        print("Greeter client received from stream: " + response.message)
}

ClassMethod ExecuteObjectScript()
{
    Set sys = $system.Python.Import("sys")
    Do sys.path.append("/usr/irissys/mgr/python/grpc-test/")

    Set grpc = $SYSTEM.Python.Import("grpc")
    Set helloworldpb2 = $SYSTEM.Python.Import("helloworld_pb2")
    Set helloworldpb2grpc = $SYSTEM.Python.Import("helloworld_pb2_grpc")

    Set channel = grpc."insecure_channel"("localhost:50051")
    
    Set stub = helloworldpb2grpc.MultiGreeterStub(channel)
    Set args = {"name": "you"}
    Set response = stub.SayHello(helloworldpb2.HelloRequest(args...))
    Write "Greeter client received: "_response.message, !
    
    Set stub = helloworldpb2grpc.MultiGreeterStub(channel)
    Set args = {"name": "you"}
    Set stream = stub.SayHelloStream(helloworldpb2.HelloRequest(args...))

    While (1) {
        Set response = stream.next()
        If (stream.done()) Quit
        Write "Greeter client received from stream: "_response.message, !
    }
}

}
