## iris-grpc-example

A hello world example adapted from the officials examples, presenting how to use gRPC with IRIS.

You can find more information on [this article] (https://community.intersystems.com/post/grpc-what-it-and-hello-world).

## Installation prerequisites

If you'd like to test the project in your environment, make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Docker installation

If the online demo is not available anymore or you would like to play with the project code, you can set up a docker container. In order to get your container running, follow these steps:

Clone/git pull the repo into any local directory

```
$ git clone git@github.com:jrpereirajr/iris-grpc-example.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

# Playing with the code

Open a cache terminal through the system terminal or through Visual Studio Code:

```bash
docker exec -it iris-grpc-example_iris_1 bash
iris session iris
```

Start our gRPC server:

```objectscript
Set server = ##class(dc.jrpereira.gRPC.HelloWorldServer).%New()
Do server.Start()
```

Now, let’s create a gRPC client to interact with this server:

```objectscript
Set client = ##class(dc.jrpereira.gRPC.HelloWorldClient).%New()
Do client.ExecutePython()
```

If all is OK, you should see a bunch of greeting messages in the terminal.

Finally, let's stop out server:

```objectscript
Do server.Stop()
```

## Using the grpcurl utility within our hello world

The [`grpcurl` utility](https://github.com/fullstorydev/grpcurl) is an equivalent to `curl` one, but here instead of act like a http client (like `curl`), we use `grpcurl` as a gRPC client to test services from a running gRPC server. So let’s use it to play a little bit more with our hello world.

First, let’s download and install the `grpcurl` utility:

```bash
cd /tmp
wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.6/grpcurl_1.8.6_linux_x86_64.tar.gz
tar -zxvf grpcurl_1.8.6_linux_x86_64.tar.gz
```

Check if the installation is OK, by typing:

```bash
./grpcurl --help
```

If all is OK, you should receive an output with all `grpcurl` options.

Start the gRPC server in a IRIS terminal session as described [above](#playing-with-the-code):

```
Set server = ##class(dc.jrpereira.gRPC.HelloWorldServer).%New()
Do server.Start()
```

Now, let’s ask what services are available in the server: 

```
./grpcurl \
	-plaintext \
	-import-path /irisrun/repo/jrpereira/python/grpc-test \
	-proto helloworld.proto \
	localhost:50051 \
	list
```

You should receive this response:

```bash
helloworld.MultiGreeter
```

As you can see, the utility returned our service defined in the proto file (`helloworld.MultiGreeter`) as a response for listing all services available.

In the command above, I put each parameter in one separated line. So, let’s explain each one:

`-plaintext`: allows using gRPC with noTLS (insecure); we’re using here because we didn’t implement a secure connection for our serve - of course should be used only in non-production environment
`-import-path` and `-proto`: path and name for the .proto file (service definition); necessary if you the server doesn’t implement reflection

After these parameters, we provide the server hostname and port, and then a `grpcurl` command, `list` in this case.

Now, let’s ask for all methods in the service `helloworld.MultiGreeter`:

```bash
./grpcurl \
	-plaintext \
	-import-path /irisrun/repo/jrpereira/python/grpc-test \
	-proto helloworld.proto \
	localhost:50051 \
	list helloworld.MultiGreeter
```

You should receive this output:

```bash
helloworld.MultiGreeter.SayHello
helloworld.MultiGreeter.SayHelloStream
```

As you can see, these are the methods defined into the proto file used to generate code for our server.

Ok, now let’s test the `SayHello()` method:

```bash
./grpcurl \
	-plaintext  \
	-d '{"name":"you"}' \
	-import-path /irisrun/repo/jrpereira/python/grpc-test \
	-proto helloworld.proto \
	localhost:50051 \
	helloworld.MultiGreeter.SayHello
```

Here is the expected output (just like our client implemented early):

```bash
{
  "message": "Hi you! :)"
}
```

Also let’s test the other method, `SayHelloStream()`:

```bash
./grpcurl \
	-plaintext -d '{"name":"you"}' \
	-import-path /irisrun/repo/jrpereira/python/grpc-test \
	-proto helloworld.proto localhost:50051 \
	helloworld.MultiGreeter.SayHelloStream

And, we should got a stream with 10 greeting messages:

{
  "message": "Hi you! :)"
}
{
  "message": "Hi you! :)"
}
...
{
  "message": "Hi you! :)"
}
```

Finally, let’s do a slight change on this command to use another property in the protobuf message, the `num_greetings` one. This property is used by the server to control how many messages will be sent in the stream.

So, this command ask the server to return only 2 messages in the stream, instead 10 by default:

```bash
./grpcurl \
	-plaintext -d '{"name":"you", "num_greetings":2}' \
	-import-path /irisrun/repo/jrpereira/python/grpc-test \
	-proto helloworld.proto localhost:50051 \
	helloworld.MultiGreeter.SayHelloStream
```

And this should be what you will see in the terminal:

```bash
{
  "message": "Hi you! :)"
}
{
  "message": "Hi you! :)"
}
```
