from collections.abc import MutableMapping
import unicodedata
import iris

from pickle import dumps, loads
import json

class IrisGlobalDict(MutableMapping, json.JSONEncoder):
    """
    https://treyhunner.com/2019/04/why-you-shouldnt-inherit-from-list-and-dict-in-python/
    https://stackoverflow.com/a/23976949/345422
    """
    def __init__(self, data=(), verbose=True):
        # todo: ###
        self.gbl = iris.gref("^test")
        self.gbl.kill([])
        self.verbose = verbose
        ###########
        # self.mapping = {}
        self.update(data)
    
    def default(self, obj):
        self.mylog(f'json default: {obj}')
        try:
            iterable = iter(obj)
        except TypeError:
            pass
        else:
            return list(iterable)
        # Let the base class default method raise the TypeError
        return json.JSONEncoder.default(self, obj)

    def __getitem__(self, key):
        self.mylog(f"__getitem__, {key}")
        return deserialize(self.gbl[key])

    def __delitem__(self, key):
        self.mylog("__delitem__")
        value = self[key]
        self.gbl.kill([key])
        self.pop(value, None)

    def __setitem__(self, key, value):
        self.mylog(f"__setitem__, {key}, {value}")
        if key in self:
            print("del self[self[key]]")
            del self[self[key]]
        if value in self:
            print("del self[value]")
            del self[value]
        # self.mapping[key] = value
        self.gbl[key] = serialize(value)

    def __iter__(self):
        self.mylog("__iter__")
        return self.gbl.orderiter()

    def __len__(self):
        self.mylog("__len__")
        return sum(1 for _ in self.gbl.orderiter())

    def __repr__(self):
        self.mylog("__repr__")
        str_repr = str([x for _, x in zip(range(5), self.gbl.query())])
        # str_repr = str([self.gbl[x] for x in self.gbl.keys()])
        # for x in self.gbl.keys(): print(self.gbl[x])
        return f"{type(self).__name__}({str_repr})"

    def mylog(self, msg):
        if self.verbose:
            print(msg)

    def clear(self):
        return self.__dict__.clear()

    def copy(self):
        return self.__dict__.copy()

    def has_key(self, k):
        return k in self.__dict__

    def update(self, items):
        if isinstance(items, dict):
            items = items.items()
        for key, value in items:
            # self[key] = value
            # print(f"{key}, {value}")
            self.__setitem__(key, value)

    # def update(self, *args, **kwargs):
    #     self.mylog(f"update {args}, {kwargs}")
    #     for k, v in args.items():
    #         print(f"k: {k}, v: {v}")
    #     return self.__dict__.update(*args, **kwargs)

    def keys(self):
        return self.__dict__.keys()

    def values(self):
        return self.__dict__.values()

    def items(self):
        return self.__dict__.items()

    def pop(self, *args):
        return self.__dict__.pop(*args)

    def __cmp__(self, dict_):
        return self.__cmp__(self.__dict__, dict_)

    def __contains__(self, item):
        return item in self.__dict__

    # def __iter__(self):
    #     return iter(self.__dict__)

    def __unicode__(self):
        return unicodedata(repr(self.__dict__))

# format = "pickle"
format = "json"

# json_encoder = json.JSONEncoder()
# json_decoder = json.JSONDecoder()

def serialize(data):
    if (format == "pickle"):
        return pickle_serialize(data)
    elif (format == "json"):
        return json_serialize(data)

# def deserialize(gbl, idx):
#     if (format == "pickle"):
#         return pickle_deserialize(gbl, idx)
#     elif (format == "json"):
#         return json_deserialize(gbl, idx)

def deserialize(data):
    if (format == "pickle"):
        return pickle_deserialize(data)
    elif (format == "json"):
        return json_deserialize(data)

def pickle_serialize(data):
    return dumps(data)

# def pickle_deserialize(gbl, idx):
#     return loads(gbl.getAsBytes(idx))

def pickle_deserialize(data):
    return loads(data)

def json_serialize(data):
    # return json.dumps(data)
    return json.dumps(data, cls=IrisGlobalDict)

# def json_deserialize(gbl, idx):
#     # return json_decoder.decode(gbl.getAsBytes(idx))
#     return json_decoder.decode(gbl[idx])

def json_deserialize(data):
    return json.loads(data)