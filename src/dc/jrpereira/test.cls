Class dc.jrpereira.test
{

ClassMethod HelloWorld() As %Status
{
  Set sc = $$$OK
  Set b = ##class(%SYS.Python).Import("builtins")
  Do b.print("Hello world")
  Return sc
}

ClassMethod Today() As %Status
{
  Set sc = $$$OK
  Set dt = ##class(%SYS.Python).Import("datetime")
  write dt.date.today().isoformat()
  Return sc
}

ClassMethod Hello() As %Status
{
  Set sc = $$$OK
  Set sm = ##class(%SYS.Python).Import("sample")
  write sm.hello()
  Return sc
}

/// Titanic
ClassMethod TitanicMeanAge() As %Status
{
    Set sc = $$$OK
    set tt=##class(%SYS.Python).Import("sample")
    set path=$System.Util.ManagerDirectory()_"data/titanic.csv"
    write "mean age="_tt.meanage(path)
    Return sc
}

ClassMethod TestIrisGlobalObject() As %Status
{
  Set sc = $$$OK
  Set IrisGlobalObjectType = ##class(%SYS.Python).Import("iris_global_object")
  Set employeeType = ##class(%SYS.Python).Import("employee")
  Set emp = employeeType.SalaryEmployee(11, "me", 123)
  Set emp.company = employeeType.Company("Company ABC")
  Set obj1 = IrisGlobalObjectType.IrisGlobalObject()
  Set obj1.prop1 = "Property 01"
  Set obj1.prop2 = emp
  Write "obj1.prop1: ", obj1.prop1, !
  Write "obj1.prop2: ", obj1.prop2, !
  Write "obj1.prop2.name: ", obj1.prop2.name, !
  Write "obj1.prop2.company.name: ", obj1.prop2.company.name, !
  Return sc
}

ClassMethod TestIrisGlobalObjectPython() [ Language = python ]
{
  from iris_global_object import IrisGlobalObject
  from employee import SalaryEmployee
  from employee import Company

  prop1_value = "Prop1"
  prop2_value = 123
  prop3_value = 123.456
  prop4_value = True
  prop5_value = None
  prop6_value = SalaryEmployee(10, "me", 123)
  prop6_value.company = Company("Company ABC")
  prop6_value.note = "note note note..."

  obj1 = IrisGlobalObject()
  obj1.prop1 = prop1_value
  obj1.prop2 = prop2_value
  obj1.prop3 = prop3_value
  obj1.prop4 = prop4_value
  obj1.prop5 = prop5_value
  obj1.prop6 = prop6_value

  print(f"obj1.prop1: {obj1.prop1}")
  print(f"obj1.prop2: {obj1.prop2}")
  print(f"obj1.prop3: {obj1.prop3}")
  print(f"obj1.prop4: {obj1.prop4}")
  print(f"obj1.prop5: {obj1.prop5}")
  print(f"obj1.prop6: {obj1.prop6}")
  print(f"obj1.prop6.name: {obj1.prop6.name}")
  print(f"obj1.prop6.company.name: {obj1.prop6.company.name}")
  print(f"obj1.prop6.calculate_payroll(): {obj1.prop6.calculate_payroll()}")
}

}
