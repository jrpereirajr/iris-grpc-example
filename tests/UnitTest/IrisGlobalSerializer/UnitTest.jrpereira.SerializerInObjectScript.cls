Class UnitTest.jrpereira.UnitTest.jrpereira.SerializerInObjectScript Extends %UnitTest.TestCase
{

Parameter GNAME = "^testSerializerInObjectScript";

Method OnAfterOneTest(testname As %String) As %Status
{
  Set gname = ..#GNAME
  Kill @gname
  Quit $$$OK
}

Method TestSerializer()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")
  Set employeeType = ##class(%SYS.Python).Import("employee")

  Set gname = ..#GNAME
  
  Set emp = employeeType.SalaryEmployee(10, "me", 123)
  Set emp.company = employeeType.Company("Company ABC")

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(emp)

  Do $$$AssertEquals(@gname@(oid,"_class"), "<class 'employee.SalaryEmployee'>")
  Do $$$AssertEquals(@gname@(oid,"id","type"),"<class 'int'>")
  Do $$$AssertEquals(@gname@(oid,"id","value"),10)
  Do $$$AssertEquals(@gname@(oid,"name","type"),"<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"name","value"),"me")
  Do $$$AssertEquals(@gname@(oid,"note","type"),"<class 'NoneType'>")
  Do $$$AssertEquals(@gname@(oid,"note","value"),"")
  Do $$$AssertEquals(@gname@(oid,"weekly_salary","type"),"<class 'int'>")
  Do $$$AssertEquals(@gname@(oid,"weekly_salary","value"),123)
  Do $$$AssertEquals(@gname@(oid,"year_salary","type"),"<class 'int'>")
  Do $$$AssertEquals(@gname@(oid,"year_salary","value"),6396)
  Set companyOID = @gname@(oid,"company","oref")
  Do $$$AssertEquals(@gname@(oid,"company","type"),"<class 'iris_global_object.IrisGlobalObject'>")
  Do $$$AssertEquals(@gname@(companyOID,"_class"),"<class 'employee.Company'>")
  Do $$$AssertEquals(@gname@(companyOID,"name","type"),"<class 'str'>")
  Do $$$AssertEquals(@gname@(companyOID,"name","value"),"Company ABC")
}

Method TestDeserializer()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")
  Set employeeType = ##class(%SYS.Python).Import("employee")

  Set gname = ..#GNAME
  
  Set emp = employeeType.SalaryEmployee(10, "me", 123)
  Set emp.company = employeeType.Company("Company ABC")

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(emp)
  Set deserializedObj = serializer.deserialize(oid)

  Do $$$AssertEquals(deserializedObj."__repr__"(), emp."__repr__"(), "should had set/get OBJECT property")
  Do $$$AssertEquals(deserializedObj."calculate_payroll"(), emp."calculate_payroll"(), "should had set/get OBJECT property")
}

Method TestSerializeDictonary()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")

  Set gname = ..#GNAME
  
  Set mycar = ##class(%SYS.Python).Builtins().dict()
  Do mycar.setdefault("maker", "Toyota")
  Do mycar.setdefault("model", "RAV4")
  Do mycar.setdefault("color", "blue")
  Do mycar.setdefault("mpg", "6.3")
  Do mycar.setdefault("firstOwner", $SYSTEM.Python.False())
  Do mycar.setdefault("seats", 5)
  Do mycar.setdefault("ensurance", $SYSTEM.Python.None())

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(mycar)

  Do $$$AssertEquals(@gname@(oid,"_class"), "<class 'dict'>")
  Do $$$AssertEquals(@gname@(oid,"color","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"color","value"), "blue")
  Do $$$AssertEquals(@gname@(oid,"ensurance","type"), "<class 'NoneType'>")
  Do $$$AssertEquals(@gname@(oid,"ensurance","value"), "")
  Do $$$AssertEquals(@gname@(oid,"firstOwner","type"), "<class 'bool'>")
  Do $$$AssertEquals(@gname@(oid,"firstOwner","value"), 0)
  Do $$$AssertEquals(@gname@(oid,"maker","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"maker","value"), "Toyota")
  Do $$$AssertEquals(@gname@(oid,"model","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"model","value"), "RAV4")
  Do $$$AssertEquals(@gname@(oid,"mpg","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"mpg","value"), 6.3)
  Do $$$AssertEquals(@gname@(oid,"seats","type"), "<class 'int'>")
  Do $$$AssertEquals(@gname@(oid,"seats","value"), 5)
}

Method TestDeserializerDictonary()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")

  Set gname = ..#GNAME
  
  Set mycar = ##class(%SYS.Python).Builtins().dict()
  Do mycar.setdefault("maker", "Toyota")
  Do mycar.setdefault("model", "RAV4")
  Do mycar.setdefault("color", "blue")
  Do mycar.setdefault("mpg", "6.3")
  Do mycar.setdefault("firstOwner", $SYSTEM.Python.False())
  Do mycar.setdefault("seats", 5)
  Do mycar.setdefault("ensurance", $SYSTEM.Python.None())

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(mycar)
  Set deserializedObj = serializer.deserialize(oid)

  Do $$$AssertEquals(deserializedObj."__getitem__"("color"), mycar."__getitem__"("color"), "should had deserialized property color")
  Do $$$AssertEquals(deserializedObj."__getitem__"("ensurance"), mycar."__getitem__"("ensurance"), "should had deserialized property ensurance")
  Do $$$AssertEquals(deserializedObj."__getitem__"("firstOwner"), mycar."__getitem__"("firstOwner"), "should had deserialized property firstOwner")
  Do $$$AssertEquals(deserializedObj."__getitem__"("maker"), mycar."__getitem__"("maker"), "should had deserialized property maker")
  Do $$$AssertEquals(deserializedObj."__getitem__"("model"), mycar."__getitem__"("model"), "should had deserialized property model")
  Do $$$AssertEquals(deserializedObj."__getitem__"("mpg"), mycar."__getitem__"("mpg"), "should had deserialized property mpg")
  Do $$$AssertEquals(deserializedObj."__getitem__"("seats"), mycar."__getitem__"("seats"), "should had deserialized property seats")
}

Method TestSerializeDictonaryWithObject()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")

  Set gname = ..#GNAME
  
  Set ensurance = ##class(%SYS.Python).Builtins().dict()
  Do ensurance.setdefault("name", "Ensurance Company")
  Do ensurance.setdefault("value", "10000")
  Do ensurance.setdefault("due", "2022-12-31")

  Set mycar = ##class(%SYS.Python).Builtins().dict()
  Do mycar.setdefault("maker", "Toyota")
  Do mycar.setdefault("model", "RAV4")
  Do mycar.setdefault("ensurance", ensurance)

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(mycar)

  Do $$$AssertEquals(@gname@(oid,"_class"), "<class 'dict'>")
  Do $$$AssertNotEquals(@gname@(oid,"ensurance","oref"), "")
  Do $$$AssertEquals(@gname@(oid,"ensurance","type"), "<class 'iris_global_object.IrisGlobalObject'>")
  Do $$$AssertEquals(@gname@(oid,"maker","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"maker","value"), "Toyota")
  Do $$$AssertEquals(@gname@(oid,"model","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"model","value"), "RAV4")

  Set oid = @gname@(oid,"ensurance","oref")
  Do $$$AssertEquals(@gname@(oid,"_class"), "<class 'dict'>")
  Do $$$AssertEquals(@gname@(oid,"due","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"due","value"), "2022-12-31")
  Do $$$AssertEquals(@gname@(oid,"name","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"name","value"), "Ensurance Company")
  Do $$$AssertEquals(@gname@(oid,"value","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"value","value"), 10000)
}

Method TestDeserializerDictonaryWithObject()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")

  Set gname = ..#GNAME
  
  Set ensurance = ##class(%SYS.Python).Builtins().dict()
  Do ensurance.setdefault("name", "Ensurance Company")
  Do ensurance.setdefault("value", "10000")
  Do ensurance.setdefault("due", "2022-12-31")

  Set mycar = ##class(%SYS.Python).Builtins().dict()
  Do mycar.setdefault("maker", "Toyota")
  Do mycar.setdefault("model", "RAV4")
  Do mycar.setdefault("ensurance", ensurance)

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(mycar)
  Set deserializedObj = serializer.deserialize(oid)

  Do $$$AssertEquals(deserializedObj."__getitem__"("maker"), mycar."__getitem__"("maker"), "should had deserialized property maker")
  Do $$$AssertEquals(deserializedObj."__getitem__"("model"), mycar."__getitem__"("model"), "should had deserialized property model")

  Set obj = deserializedObj."__getitem__"("ensurance")
  Do $$$AssertEquals(obj."__getitem__"("due"), ensurance."__getitem__"("due"), "should had deserialized property due")
  Do $$$AssertEquals(obj."__getitem__"("name"), ensurance."__getitem__"("name"), "should had deserialized property name")
  Do $$$AssertEquals(obj."__getitem__"("value"), ensurance."__getitem__"("value"), "should had deserialized property value")
}

Method TestSerializeList()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")

  Set gname = ..#GNAME
  
  Set mylist = ##class(%SYS.Python).Builtins().list()
  Do mylist.append("apple")
  Do mylist.append("banana")
  Do mylist.append("cherry")

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(mylist)

  Do $$$AssertEquals(@gname@(oid,"_class"), "<class 'list'>")
  Do $$$AssertEquals(@gname@(oid,"idx0","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"idx0","value"), "apple")
  Do $$$AssertEquals(@gname@(oid,"idx1","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"idx1","value"), "banana")
  Do $$$AssertEquals(@gname@(oid,"idx2","type"), "<class 'str'>")
  Do $$$AssertEquals(@gname@(oid,"idx2","value"), "cherry")
}

Method TestDeserializerList()
{
  Set IrisGlobalSerializerType = ##class(%SYS.Python).Import("iris_global_serializer")

  Set gname = ..#GNAME
  
  Set mylist = ##class(%SYS.Python).Builtins().list()
  Do mylist.append("apple")
  Do mylist.append("banana")
  Do mylist.append("cherry")

  Set serializer = IrisGlobalSerializerType.IrisGlobalSerializer(gname)
  Set oid = serializer.serialize(mylist)
  Set deserializedObj = serializer.deserialize(oid)

  Do $$$AssertEquals(deserializedObj."__repr__"(), mylist."__repr__"(), "should had deserialized same values, in same order")
}

}
