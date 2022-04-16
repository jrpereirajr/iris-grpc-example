from iris_global_dict import IrisGlobalDict

from sys import getsizeof
from memory_usage import total_size, deep_getsizeof

def test1():
    test_dict = dict()
    test_dict[1] = [2,3]
    test_dict[2] = "abc"
    test_dict[3] = [x for x in range(100)]
    print(test_dict)
    print(getsizeof(test_dict))
    print(total_size(test_dict))
    print(deep_getsizeof(test_dict))

    test_dict = IrisGlobalDict()
    test_dict[1] = [2,3]
    test_dict[2] = "abc"
    test_dict[3] = [x for x in range(100)]
    print(test_dict)
    print(getsizeof(test_dict))
    print(total_size(test_dict))
    print(deep_getsizeof(test_dict))

def test2():
    dict_1 = IrisGlobalDict({'jack': 4098, 'sape': 4139})
    print(dict_1)

    dict_2 = IrisGlobalDict({
        "key1": dict_1
    })
    print(dict_2)

def test3():
    thisdict = IrisGlobalDict({
        "brand": "Ford",
        "electric": False,
        "year": 1964,
        "colors": ["red", "white", "blue"]
    })
    print(thisdict)

def test4():
    tel = IrisGlobalDict({'jack': 4098, 'sape': 4139})
    tel['guido'] = 4127
    print(tel)
    print(tel['jack'])
    del tel['sape']
    tel['irv'] = 4127
    print(tel)
    print(list(tel))
    print(sorted(tel))
    print('guido' in tel)
    print('jack' not in tel)

user_input = None
while user_input != "":
    user_input = input("which test function: ")
    if user_input != "":
        eval(f"test{user_input}()")