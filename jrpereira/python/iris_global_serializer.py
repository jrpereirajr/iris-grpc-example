import string
from typing import Any
from iris_global_object import IrisGlobalObject

class IrisGlobalSerializer:
    def __init__(self, gname: string=None) -> None:
        self.gname = gname

    def serialize(self, __data: Any, gname: string=None) -> string:
        if gname is None:
            gname = self.gname
        wrapper = IrisGlobalObject(oref=__data, gname=gname)
        return wrapper.oid

    def deserialize(self, goref:string, gname: string=None) -> Any:
        if gname is None:
            gname = self.gname
        return IrisGlobalObject(goref=goref,gname=gname)