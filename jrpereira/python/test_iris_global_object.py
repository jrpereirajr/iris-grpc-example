from iris_global_object import IrisGlobalObject
from employee import SalaryEmployee

# print(SalaryEmployee(1,'me',123).__dict__)

obj1 = IrisGlobalObject()
obj1.prop1 = 'Prop1'
obj1.prop2 = 123
obj1.prop3 = 123.456
obj1.prop4 = True
obj1.prop5 = None
emp = SalaryEmployee(10,'me',123)
emp.note = 'note note note...'
obj1.prop6 = emp
# obj1.prop6.note = 'updated note prop6!'
obj1.prop6_1 = SalaryEmployee(11,'me',123)
obj1.prop6_1.note = 'note note prop6_1...'
# obj1.prop7 = [1,2]
print(f"obj1: {obj1}")
print(f"obj1.prop6: {obj1.prop6}")
print(f"obj1.prop6.oref: {obj1.prop6.oref}")
print(f"obj1.prop6_1: {obj1.prop6_1}")
print(f"obj1.prop6_1.oref: {obj1.prop6_1.oref}")
print(f"obj1.prop6.calculate_payroll(): {obj1.prop6.calculate_payroll()}")
print(f"obj1.prop6_1.calculate_payroll(): {obj1.prop6_1.calculate_payroll()}")

def introspect_test():
    # args = dict()
    # args["id"] = 2
    # args["name"] = "me me"
    # args["weekly_salary"] = 321
    # print(args)
    # print(SalaryEmployee(**args))

    import inspect
    signature = inspect.signature(SalaryEmployee.__init__)
    # print(dir(signature))
    # for name, parameter in signature.parameters.items():
    #     print({"name": name, "default": parameter.default, "annotation": parameter.annotation, "kind": parameter.kind})
    #     # print(name, parameter)
    print([name for name, parameter in signature.parameters.items()])

# obj2 = IrisGlobalObject(goref=obj1.prop6.oid)
# print(f"obj2: {obj2}")

# introspect_test()