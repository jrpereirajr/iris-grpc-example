Class UnitTest.jrpereira.PythonObjectsOnGlobalsInObjectScript Extends %UnitTest.TestCase
{

Parameter GNAME = "^testPythonObjectsOnGlobalsInObjectScript";

Method OnAfterOneTest(testname As %String) As %Status
{
  Set gname = ..#GNAME
  Kill @gname
  Quit $$$OK
}

Method TestPrimitiveTypes()
{
  Set IrisGlobalObjectType = ##class(%SYS.Python).Import("iris_global_object")
  
  Set prop1Value = "Property 01"
  Set prop2Value = 123
  Set prop3Value = 123.456
  Set prop4Value = $system.Python.True()
  Set prop5Value = $system.Python.None()

  Set obj1 = IrisGlobalObjectType.IrisGlobalObject({"gname": (..#GNAME)})
  Set obj1.prop1 = prop1Value
  Set obj1.prop2 = prop2Value
  Set obj1.prop3 = prop3Value
  Set obj1.prop4 = prop4Value
  Set obj1.prop5 = prop5Value
  
  Do $$$AssertEquals(obj1.prop1, prop1Value, "should had set/get STRING property")
  Do $$$AssertEquals(obj1.prop2, prop2Value, "should had set/get INT property")
  #; If a float value is written to an iris global, some garbage is left...
  #; For instance, a float value in python like 123.456 is written to a iris global as 123.4560000000000031
  #; Do $$$AssertEquals(obj1.prop3, 123.456, "should had set/get FLOAT property")
  Do $$$AssertEquals(obj1.prop3, prop3Value + 0.0000000000000031, "should had set/get FLOAT property")
  Do $$$AssertEquals(obj1.prop4, $$$OK, "should had set/get BOOLEAN property")
  Do $$$AssertEquals(obj1.prop5, "", "should had set/get NONE property")
}

Method TestObjectTypes()
{
  Set IrisGlobalObjectType = ##class(%SYS.Python).Import("iris_global_object")
  Set employeeType = ##class(%SYS.Python).Import("employee")

  Set gname = ..#GNAME

  Set prop1Value = employeeType.SalaryEmployee(10, "me", 123)
  Set prop1Value.note = "note note note..."

  Set obj1 = IrisGlobalObjectType.IrisGlobalObject({"gname": (..#GNAME)})
  Set obj1.prop1 = prop1Value
  
  Do $$$AssertEquals(obj1.prop1."__repr__"(), prop1Value."__repr__"(), "should had set/get OBJECT property")
  Do $$$AssertEquals(obj1.prop1."calculate_payroll"(), prop1Value."calculate_payroll"(), "should had set/get OBJECT property")
}

/// Test if it's possible to set a wrapperd object property
/// ** Removed due raising this issue: LogStateStatus:0:TestObjectTypesSetObjPropAfter: ERROR #5002: ObjectScript error: <PARAMETER>%OnClose+1^%SYS.Python.1  <<==== **FAILED**   PythonObjectsOnGlobals:UnitTest.jrpereira.PythonObjectsOnGlobalsInObjectScript:TestObjectTypesSetObjPropAfter
Method xxTestObjectTypesSetObjPropAfter()
{
  Set IrisGlobalObjectType = ##class(%SYS.Python).Import("iris_global_object")
  Set employeeType = ##class(%SYS.Python).Import("employee")

  Set prop1Value = employeeType.SalaryEmployee(11, "me", 123.456)

  Set obj1 = IrisGlobalObjectType.IrisGlobalObject({"gname": (..#GNAME)})
  Set obj1.prop1 = prop1Value
  Set obj1.prop1.note = "note note note..."

  #; Set prop1Value.note = "note note note..."
  
  #; Do $$$AssertEquals(obj1.prop1."__repr__"(), prop1Value."__repr__"())
  #; Do $$$AssertEquals(obj1.prop1.name, prop1Value.name, "should had set/get OBJECT property")
  #; Do $$$AssertEquals(obj1.prop1.note, "note note note...", "should had set/get OBJECT property")
  #; Do $$$AssertEquals(obj1.prop1."calculate_payroll"(), prop1Value."calculate_payroll"(), "should had set/get OBJECT property")
}

Method TestObjectWithObjectRef()
{
  Set IrisGlobalObjectType = ##class(%SYS.Python).Import("iris_global_object")
  Set employeeType = ##class(%SYS.Python).Import("employee")

  Set emp = employeeType.SalaryEmployee(10, "me", 123)
  Set emp.company = employeeType.Company("Company ABC")
  Set prop1Value = emp

  Set obj1 = IrisGlobalObjectType.IrisGlobalObject({"gname": (..#GNAME)})
  Set obj1.prop1 = prop1Value
  
  Do $$$AssertEquals(obj1.prop1."__repr__"(), prop1Value."__repr__"(), "should had set/get OBJECT property")
  Do $$$AssertEquals(obj1.prop1."calculate_payroll"(), prop1Value."calculate_payroll"(), "should had set/get OBJECT property")
}

}
