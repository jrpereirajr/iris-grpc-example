Class dc.jrpereira.gRPC.HelloWorldServer Extends %RegisteredObject
{

Property pid As %Integer;

Method GetStartServerCommnad() As %String
{
    Set cmd = "exec /usr/irissys/bin/irispython /usr/irissys/mgr/python/grpc-test/greeter_server.py --port %1"
    Return cmd
}

Method Start() As %Status
{
    // todo: create logic based on globals to avoid multiple servers in same port
    
    Set port = 50051
    Set cmd = $$$FormatText(..GetStartServerCommnad(), port)
    Set osSignal = $ZF(-2, cmd, "", "", 1)
    If (osSignal '= 0) {
        Throw ..CreateOsNonZeroSignalExpcetion(osSignal)
    }
    Set ..pid = $ZChild

    // give some time to server starts and check if did it
    Set attempts = 0
    While (..pid = "") || ($SYSTEM.Process.JobType(..pid) = 0) {
        If (attempts > 50) {
            Set msg = "Server couldn't be started. Check if that command is OK: "_cmd
            Throw ##class(%Exception.General).%New(msg)
        }
        Hang 0.1
        Set attempts = attempts + 1
    }

    Quit $$$OK
}

Method Stop() As %Status
{
    If (..pid = "") {
        Set msg = "No PID"
        Throw ##class(%Exception.General).%New(msg)
    }

    Set osSignal = $ZF(-1, "kill "_..pid)
    If (osSignal '= 0) {
        Throw ..CreateOsNonZeroSignalExpcetion(osSignal)
    }

    Set ..pid = ""

    Quit $$$OK
}

Method Restart() As %Status
{
    $$$ThrowOnError(..Stop())
    $$$ThrowOnError(..Start())
    Quit $$$OK
}

Method CreateOsNonZeroSignalExpcetion(pOsSignal) As %Exception.AbstractException
{
    Set msg = "Operating system returned a non-zero status: "_pOsSignal
    Return ##class(%Exception.General).%New(msg)
}

Method SayHelloPython(request) [ Language = python ]
{
    import sys
    sys.path.append('/usr/irissys/mgr/python/grpc-test/')

    from helloworld_pb2 import HelloReply

    return HelloReply(message='Hi, %s!!!' % request.name)
}

Method SayHelloObjectScript(request)
{
    Set sys = $system.Python.Import("sys")
    Do sys.path.append("/usr/irissys/mgr/python/grpc-test/")

    Set helloworldpb2 = $system.Python.Import("helloworld_pb2")

    Set reply = helloworldpb2.HelloReply()
    Set reply.message = "Hi "_request.name_"! :)"

    Return reply
}

}
