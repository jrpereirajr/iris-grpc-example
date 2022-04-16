import iris
from typing import Any, MutableMapping, MutableSequence
import re
import inspect
import traceback

class IrisGlobalObject(object):

    """
    A wrapper to store Python object using globals structure in IRIS database
    """

    my_props = ("oid", "gbl", "gname", "oref", "primitive", "verbose")
    primitive = (int, float, str, bool, type(None))

    def __init__(self, oref: object=None, goref=None, gname="^pythonheap", verbose=False) -> None:
        self.verbose = verbose
        self.mylog(f"__init__()")
        
        self.gname = gname
        self.gbl = iris.gref(gname)
        curr_idx = self.get_global_index()
        self.oid = curr_idx
        self.mylog(f"oid: {curr_idx}")

        if not oref is None:
            self.load(oref)
        elif not goref is None:
            obj = self.load_obj_from_global_oref(goref)
            self.load(obj)
        # else:
        #     self.gbl[self.oid, "_class"] = str(type(self))

    def get_global_index(self):
        # todo: implement concurrency proof global in index increment
        curr_idx = self.gbl["idx"]
        if curr_idx is None: curr_idx = 0    
        curr_idx = curr_idx + 1
        self.gbl.set(["idx"], curr_idx)
        return curr_idx

    def load(self, oref):
        self.mylog(f"load({oref})")
        self.gbl[self.oid, "_class"] = str(type(oref))
        if isinstance(oref, MutableMapping):
            for prop in oref.keys():
                setattr(self, prop, oref[prop])
        elif isinstance(oref, MutableSequence):
            for idx, item in enumerate(oref):
                setattr(self, "idx"+str(idx), item)
        else:
            if hasattr(oref, "__dict__"):
                for prop in oref.__dict__:
                    setattr(self, prop, getattr(oref, prop))

    def get_class_type(self, class_type_name):
        self.mylog(f"get_class_type({class_type_name})")
        p = re.compile("<class '(.*)'>")
        p = p.match(class_type_name)
        if p is None:
            return None
        class_type_name = p.group(1)
        parts = class_type_name.split('.')
        if len(parts) > 1:
            module = ".".join(parts[:-1])
            parts = parts[1:]
        else:
            module = "builtins"
        m = __import__(module)
        for comp in parts:
            m = getattr(m, comp)
        return m
    
    def get_class_init_parameters(self, class_type):
        self.mylog(f"get_class_init_parameters({class_type})")
        signature = inspect.signature(class_type.__init__)
        return [name for name, parameter in signature.parameters.items()]

    def load_obj_from_global_oref(self, goref):
        self.mylog(f"load_obj_from_global_oref({goref})")
        if self.gbl[goref]:
            return
        
        obj_class = self.gbl[goref, "_class"]
        
        class_type = self.get_class_type(obj_class)
        class_init_params = self.get_class_init_parameters(class_type)
        init_params = {}
        other_props = {}

        prop = self.gbl.order([goref, "_class"])
        while not prop is None:
            prop_type = self.gbl[goref, prop, "type"]
            prop_value = self.gbl[goref, prop, "value"]
            prop_oref = self.gbl[goref, prop, "oref"]

            if not prop_oref is None:
                prop_value = IrisGlobalObject(goref=prop_oref, gname=self.gname).oref
            elif prop_type == str(True.__class__):
                prop_value = True if prop_value == 1 else False
            elif prop_type == str(None.__class__):
                prop_value = None
            
            if prop in class_init_params:
                init_params[prop] = prop_value
            else:
                other_props[prop] = prop_value

            prop = self.gbl.order([goref, prop])

        obj = class_type(**init_params)
        for prop, value in other_props.items():
            if isinstance(obj, MutableMapping):
                obj[prop] = value
            elif isinstance(obj, MutableSequence):
                obj.append(value)
            else:
                setattr(obj, prop, value)
            
        wrapper = IrisGlobalObject(gname=self.gname)
        wrapper.oref = obj
        wrapper.oid = goref
        return wrapper
    
    # def __del__(self) -> None:
    #     self.mylog(f"__del__({self})")
    #     # todo:
    #     # self.gbl.kill([self.oid])
    
    def set_heap(self, prop_name, prop_value):
        self.mylog(f"set_heap: {prop_name}, {prop_value}")
        self.mylog(f"oid: {self.oid}")

        prop_type = type(prop_value)
        self.gbl[self.oid, prop_name, "type"] = str(prop_type)

        if prop_type == bool:
            self.gbl[self.oid, prop_name, "value"] = 1 if prop_value else 0
        elif prop_value is None:
            self.gbl[self.oid, prop_name, "value"] = ""
        elif isinstance(prop_value, IrisGlobalObject.primitive):
            self.gbl[self.oid, prop_name, "value"] = prop_value
        else:
            self.gbl[self.oid, prop_name, "oref"] = prop_value.oid
    
    def get_heap(self, prop_name):
        self.mylog(f"get_heap: {prop_name}")
        self.mylog(f"oid: {self.oid}")
        
        prop_type = self.gbl[self.oid, prop_name, "type"]
        gbl_value =  self.gbl[self.oid, prop_name, "value"]
        oref = self.gbl[self.oid, prop_name, "oref"]
        if prop_type == str(True.__class__):
            return False if int(gbl_value) == 0 else True
        elif prop_type == str(None.__class__):
            return None
        elif not oref is None:
            return self.load_obj_from_global_oref(goref=oref)
        else:
            return gbl_value

    def __setattr__(self, __name: str, __value: Any) -> None:
        self.mylog(f"__setattr__({__name}, {__value})")

        if __name in IrisGlobalObject.my_props: # todo: try to use hasattr(self, __name)
            super().__setattr__(__name, __value)
        else:
            if self.gbl[self.oid, "_class"] is None:
                self.gbl[self.oid, "_class"] = str(type(self))

            # if oref is valid and has a __name attr, set it up
            if not self.oref is None and hasattr(self.oref, __name):
                setattr(self.oref, __name, __value)
            
            # serialize the attr
            if isinstance(__value, IrisGlobalObject.primitive):
                self.set_heap(__name, __value)
            else: # __value is an object
                child_oref = IrisGlobalObject(oref=__value, gname=self.gname)
                self.set_heap(__name, child_oref)

    def __getattr__(self, __name: str) -> Any:
        if __name in IrisGlobalObject.my_props: return  # todo: try to use hasattr(self, __name)
        self.mylog(f"__getattr__({__name})")
        if not self.oref is None and callable(getattr(self.oref, __name)):
            # returns a method
            value = getattr(self.oref, __name)
        else:
            # returns a property
            value = self.get_heap(__name)
        return value
    
    def __delattr__(self, __name: str) -> None:
        self.mylog(f"__delattr__({__name})")

    def __repr__(self) -> str:
        self.mylog(f"__repr__, {self.oid}, {self.gbl[self.oid]}")
        if not self.oref is None:
            str_repr = self.oref.__repr__()
        else:
            # todo: get repr from globals data
            # str_repr = str([x for _, x in zip(range(5), self.gbl.query([self.oid]))])
            # str_repr = str([x for x in self.gbl.orderiter([self.oid])])
            str_repr = str(super().__repr__())
        return str_repr

    def mylog(self, msg):
        if self.verbose:
            print(msg)

    def varprint(self, var):
        # source: https://stackoverflow.com/a/26240512/345422
        stack = traceback.extract_stack()
        filename, lineno, function_name, code = stack[-2]
        vars_name = re.compile(r'\((.*?)\).*$').search(code).groups()[0]
        # print(f"{vars_name}: {var} [{(filename, lineno, function_name)}]")
        print(f"{vars_name}: {var}")
        return