class Employee:
    def __init__(self, id, name, company=None):
        self.id = id
        self.name = name
        self.company = company

class SalaryEmployee(Employee):
    def __init__(self, id, name, weekly_salary = ""):
        super().__init__(id, name)
        self.weekly_salary = weekly_salary
        self.year_salary = weekly_salary * 52
        self.note = None

    def calculate_payroll(self):
        return self.weekly_salary
    
    def __repr__(self):
        s = str({"id": self.id, "name": self.name, "weekly_salary": self.weekly_salary, "year_salary": self.year_salary, "note": self.note, "company": self.company})
        return f"SalaryEmployee: {s}"

class Company:
    def __init__(self, name):
        self.name = name
    
    def __repr__(self) -> str:
        s = str({"name": self.name})
        return s