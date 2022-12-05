from collections import namedtuple
import json

def read_dress_data_from_fil(path):
    Dress = namedtuple("Dress", ["name", "fashion", "warmness"])
    f = open(path)
    data = json.load(f)
    f.close()

    dress_list = []
    for row in data:
        dress_list.append(Dress(row["name"], row["fashion"], row["warmness"]))
    return dress_list


