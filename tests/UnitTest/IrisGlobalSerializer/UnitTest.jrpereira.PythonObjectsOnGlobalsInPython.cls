/// Same tests written in UnitTest.jrpereira.PythonObjectsOnGlobalsInObjectScript, but in Python =)
Class UnitTest.jrpereira.PythonObjectsOnGlobalsInPython Extends %UnitTest.TestCase
{

Parameter GNAME = "^testPythonObjectsOnGlobalsInPython";

Method OnAfterOneTest(testname As %String) As %Status
{
  Set gname = ..#GNAME
  Kill @gname
  Quit $$$OK
}

Method AssertEquals(pLeftValue = "", pRightValue = "", pMsg = "")
{
  If (pMsg = "") {
    Do $$$AssertEquals(pLeftValue, pRightValue)
  } Else {
    Do $$$AssertEquals(pLeftValue, pRightValue, pMsg)
  }
}

Method TestPrimitiveTypesPython() [ Language = python ]
{
  from iris_global_object import IrisGlobalObject
  from employee import SalaryEmployee

  gname = self._GetParameter("GNAME")

  prop1_value = "Property 01"
  prop2_value = 123
  prop3_value = 123.456
  prop4_value = True
  prop5_value = None

  obj1 = IrisGlobalObject(gname=gname)
  obj1.prop1 = prop1_value
  obj1.prop2 = prop2_value
  obj1.prop3 = prop3_value
  obj1.prop4 = prop4_value
  obj1.prop5 = prop5_value

  self.AssertEquals(obj1.prop1, prop1_value, "should had set/get STRING type property")
  self.AssertEquals(obj1.prop2, prop2_value, "should had set/get INT type property")
  self.AssertEquals(obj1.prop3, prop3_value, "should had set/get FLOAT type property")
  self.AssertEquals(obj1.prop4, prop4_value)
  self.AssertEquals(obj1.prop5, prop5_value, "should had set/get NONE type property")
}

Method TestObjectTypes() [ Language = python ]
{
  from iris_global_object import IrisGlobalObject
  from employee import SalaryEmployee

  gname = self._GetParameter("GNAME")

  prop1_value = SalaryEmployee(10, "me", 123)
  prop1_value.note = "note note note..."

  obj1 = IrisGlobalObject(gname=gname)
  obj1.prop1 = prop1_value

  self.AssertEquals(str(obj1.prop1.oref), str(prop1_value), "should had set/get OBJECT property")
  self.AssertEquals(obj1.prop1.calculate_payroll(), prop1_value.calculate_payroll(), "should had set/get OBJECT property")
}

/// Test if it's possible to set a wrapperd object property
Method TestObjectTypesSetObjPropAfter() [ Language = python ]
{
  from iris_global_object import IrisGlobalObject
  from employee import SalaryEmployee

  gname = self._GetParameter("GNAME")

  prop1_value = SalaryEmployee(10, "me", 123)

  obj1 = IrisGlobalObject(gname=gname)
  obj1.prop1 = prop1_value
  obj1.prop1.note = "note note note..."

  prop1_value.note = "note note note..."

  self.AssertEquals(str(obj1.prop1.oref), str(prop1_value), "should had set/get OBJECT property")
  self.AssertEquals(obj1.prop1.calculate_payroll(), prop1_value.calculate_payroll(), "should had set/get OBJECT property")
}

Method TestObjectWithObjectRef() [ Language = python ]
{
  from iris_global_object import IrisGlobalObject
  from employee import SalaryEmployee, Company

  gname = self._GetParameter("GNAME")

  prop1_value = SalaryEmployee(10, "me", 123)
  prop1_value.company = Company("Company ABC")

  obj1 = IrisGlobalObject(gname=gname)
  obj1.prop1 = prop1_value
  
  self.AssertEquals(str(obj1.prop1.oref), str(prop1_value), "should had set/get OBJECT property")
  self.AssertEquals(obj1.prop1.calculate_payroll(), prop1_value.calculate_payroll(), "should had set/get OBJECT property")
}

}
