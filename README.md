## iris-grpc-example

todo:

## Online demo

A [online demo](https://serializer.demo.community.intersystems.com/terminal/) was setup for the [InterSystems Globals Contest](https://community.intersystems.com/post/intersystems-globals-contest). You can use it for your convenience during the event.

Use this credentials:

- username: _system
- password: SYS

## Installation prerequisites

If you'd like to test the project in your environment, make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## ZPM installation

```
USER>zpm "install iris-grpc-example"
```

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

## Simple demo

In this simple example, we'll create Python objects and serialize them to the global `^test`. After that, we'll deserialize the objects stored in the global again to Python objects in memory.

Open IRIS terminal (or the [online version](https://serializer.demo.community.intersystems.com/terminal/)):

```
$ docker-compose exec iris iris session iris
USER>
```

First, let's ensure that our storage global is empty:

```
USER>zw ^test

```

Now, lets access the IRIS Embedded Python terminal in order to create some Python objects and serialize them to IRIS globals:

```
USER>Do $system.Python.Shell()

Python 3.8.10 (default, Sep 28 2021, 16:10:42) 
[GCC 9.3.0] on linux
Type quit() or Ctrl-D to exit this shell.
>>> from iris_global_serializer import IrisGlobalSerializer
>>> from employee import SalaryEmployee, Company
>>> emp = SalaryEmployee(10, "me", 123)
>>> emp.note = "Note note note..."
>>> emp.company = Company("Company ABC")
>>> emp
SalaryEmployee: {'id': 10, 'name': 'me', 'weekly_salary': 123, 'year_salary': 6396, 'note': 'Note note note...', 'company': {'name': 'Company ABC'}}
>>> serializer = IrisGlobalSerializer(gname="^test")
>>> goref = serializer.serialize(emp)
>>> goref
1
>>> quit()
```

If things went as expected, we are able to see the Python objects data in the global `^test`. So, let check such global content in the terminal:

```
USER>zw ^test
^test(1,"class")="<class 'employee.SalaryEmployee'>"
^test(1,"company","oref")=2
^test(1,"company","type")="<class 'iris_global_object.IrisGlobalObject'>"
^test(1,"id","type")="<class 'int'>"
^test(1,"id","value")=10
^test(1,"name","type")="<class 'str'>"
^test(1,"name","value")="me"
^test(1,"note","type")="<class 'str'>"
^test(1,"note","value")="Note note note..."
^test(1,"weekly_salary","type")="<class 'int'>"
^test(1,"weekly_salary","value")=123
^test(1,"year_salary","type")="<class 'int'>"
^test(1,"year_salary","value")=6396
^test(2,"class")="<class 'employee.Company'>"
^test(2,"name","type")="<class 'str'>"
^test(2,"name","value")="Company ABC"
^test("idx")=2
```

As we can see, the data inputted in the Python objects was stored in the global `^test`. the first global node is an object identifier. In the second node, object properties names are stored. Finally, the third node stores properties metadata, such as type, value and oref (when the property is an object). 

Note that the node `^test(1,"company","oref")=2` refers to the node `^test(2)`, which points to another object.

Ok, now lets deserialize the object stored in the global again to a Python object:

```
USER>Do $system.Python.Shell()

Python 3.8.10 (default, Sep 28 2021, 16:10:42) 
[GCC 9.3.0] on linux
Type quit() or Ctrl-D to exit this shell.
>>> from iris_global_serializer import IrisGlobalSerializer
>>> serializer = IrisGlobalSerializer(gname="^test")
>>> goref = 1
>>> deserializedObj = serializer.deserialize(goref)
>>> deserializedObj
SalaryEmployee: {'id': 10, 'name': 'me', 'weekly_salary': 123, 'year_salary': 6396, 'note': 'Note note note...', 'company': {'name': 'Company ABC'}}
>>> quit()
```

Note that the deserialized object has the same information as the initial object created early.

You can also change the information stored in globals directly:

```
USER>Set ^test(1,"name","value")="José"
USER>Set ^test(2,"name","value")="Shift" 

USER>Do $system.Python.Shell()

Python 3.8.10 (default, Sep 28 2021, 16:10:42) 
[GCC 9.3.0] on linux
Type quit() or Ctrl-D to exit this shell.
>>> from iris_global_serializer import IrisGlobalSerializer
>>> goref = 1
>>> serializer = IrisGlobalSerializer(gname="^test")
>>> deserializedObj = serializer.deserialize(goref)
>>> deserializedObj
SalaryEmployee: {'id': 10, 'name': 'José', 'weekly_salary': 123, 'year_salary': 6396, 'note': 'Note note note...', 'company': {'name': 'Shift'}}
>>> quit()
```

Also, changes in Python object are reflected in the binded global:

```
USER>Do $system.Python.Shell()

Python 3.8.10 (default, Sep 28 2021, 16:10:42) 
[GCC 9.3.0] on linux
Type quit() or Ctrl-D to exit this shell.
>>> from iris_global_serializer import IrisGlobalSerializer
>>> goref = 1
>>> serializer = IrisGlobalSerializer(gname="^test")
>>> deserializedObj = serializer.deserialize(goref)
>>> deserializedObj.note = "Updated note..."
>>> quit()

USER>zw ^test
^test(1,"class")="<class 'employee.SalaryEmployee'>"
^test(1,"company","oref")=2
^test(1,"company","type")="<class 'iris_global_object.IrisGlobalObject'>"
^test(1,"id","type")="<class 'int'>"
^test(1,"id","value")=10
^test(1,"name","type")="<class 'str'>"
^test(1,"name","value")="José"
^test(1,"note","type")="<class 'str'>"
^test(1,"note","value")="Updated note..."
^test(1,"weekly_salary","type")="<class 'int'>"
^test(1,"weekly_salary","value")=123
^test(1,"year_salary","type")="<class 'int'>"
^test(1,"year_salary","value")=6396
^test(2,"class")="<class 'employee.Company'>"
^test(2,"name","type")="<class 'str'>"
^test(2,"name","value")="Shift"
^test("idx")=2
```

You can also find other examples in the [unit test folder](https://github.com/jrpereirajr/iris-grpc-example/tree/master/tests/UnitTest/IrisGlobalSerializer).

To run the unit tests, execute this command:

```
USER>zpm "iris-grpc-example test -v"
```

## Todo list:

- Implement serialization/deserialization to Python collection types
- Do some performance tests
