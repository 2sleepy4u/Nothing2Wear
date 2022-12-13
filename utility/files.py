from collections import namedtuple
from utility.vestiti import body_parts, body_parts_index, Dress
import json

def read_from_file(path):
    f = open(path)
    data = json.load(f)
    f.close()
    return data

    data_array = []

    for i, item in enumerate(data):
        data_array.append(data[item])

def save_to_file(path, data):
    f = open(path, "w")
    f.write(json.dumps(data))
    f.close()


def parse_to_json():
    test = {}

    for i, part in enumerate(body_parts):
        index = body_parts_index[i]
        test[index] = []
        for j, dress in enumerate(part):
            fashion = round(dress.fashion / 2, 1)
            warmness = round(dress.warmness / 2, 1)
            itm = Dress(dress.name, fashion, warmness)
            test[index].append(itm._asdict())

    test = json.dumps(test)

    f = open("vestiti.json", "w")
    f.write(test)
    f.close()
