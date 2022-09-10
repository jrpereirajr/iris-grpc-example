Class UnitTest.jrpereira.grpc.Test Extends %UnitTest.TestCase
{

Property server As dc.jrpereira.gRPC.HelloWorldServer;

Method OnBeforeOneTest(testname As %String) As %Status
{
  Set ..server = ##class(dc.jrpereira.gRPC.HelloWorldServer).%New()
  Quit $$$OK
}

Method OnAfterOneTest(testname As %String) As %Status
{
  Try {
    Do ..server.Stop()
  } Catch(e) {}

  Set oref = ..server
  Kill oref

  Kill ^SPOOL(1)

  Quit $$$OK
}

Method TestServerStartStop()
{
    Set availableBefore = $System.License.LUAvailable()
    Set startStatus = ..server.Start()
    Set stopStatus = ..server.Stop()
    Set availableAfter = $System.License.LUAvailable()

    Do $$$AssertEquals(startStatus, 1)
    Do $$$AssertEquals(stopStatus, 1)
    Do $$$AssertEquals(..server.pid, "")
    #; Do $$$AssertTrue(availableBefore = availableAfter)
}

Method TestClients()
{
    Set availableBefore = $System.License.LUAvailable()
    Set startStatus = ..server.Start()

    Try {
      Set docId = 1
      Kill ^SPOOL(docId)
      Open 2:docId
      Use 2
      Try {
        Set client = ##class(dc.jrpereira.gRPC.HelloWorldClient).%New()
        Do ##class(dc.jrpereira.gRPC.HelloWorldClient).ExecutePython()
      } Catch(e) {}
      Close 2
    } Catch(e) {}

    Set stopStatus = ..server.Stop()
    Set availableAfter = $System.License.LUAvailable()

    Do $$$AssertEquals(startStatus, 1)
    Do $$$AssertEquals(stopStatus, 1)
    Do $$$AssertEquals(..server.pid, "")
    Do $$$AssertEquals(^SPOOL(docId, 1), "Greeter client received: Hi you! :)"_$c(10))
    For i = 2:1:11 {
      Do $$$AssertEquals(^SPOOL(docId, i), "Greeter client received from stream: Hello number "_(i - 2)_", you!"_$c(10))
    }
    Do $$$AssertEquals(^SPOOL(docId, 12), "Greeter client received: Hi you! :)"_$c(13,10))
    For i = 13:1:21 {
      Do $$$AssertEquals(^SPOOL(docId, i), "Greeter client received from stream: Hello number "_(i - 13)_", you!"_$c(13,10))
    }
    #; Do $$$AssertTrue(availableBefore = availableAfter)
}

}
