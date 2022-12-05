from functools import partial
import json
from flask import Flask, request, Response
# custom
from utility.temperature import get_today_temperature
from utility.genetic_algorithm import *
from utility.logging import solution_to_json
from utility.vestiti import body_parts
from utility.geocoding import get_city_coord
from utility.options import *

# app
app = Flask(__name__)

@app.route('/')
def index():
    return "Hello World!"

@app.get('/generate')
def get_outfit():
    # Inputs data
    fashion     = int(request.args.get('fashion', -1))
    temperature = int(request.args.get("temperature", 0))
    city        = request.args.get("city", "")

    print(f"Outfit request for {city} with min fashion {fashion}")

    if city == "":
        print(f"City error: city not specified")
        return Response('{"Error": "city not specified"}', status=400, mimetype='application/json')

    if fashion == -1:
        print(f"Fashion Error: fashion level not specified")
        return Response('{"Error": "fashion level not specified"}', status=400, mimetype='application/json')

    if fashion > 10 or fashion < 1:
        print(f"Range error: {fashion} is out of range (1-10)")
        return Response('{"Error": "Fashion level out of range (1-10)"}', status=400, mimetype='application/json')

    return generate_outfit(city, fashion, temperature)
  
@app.post('/generate')
def post_outfit():
    data = request.get_json()
    data = json.dumps(data)

    fashion     = data["fashion"]
    temperature = data["temperature"]
    city        = data["city"]

    print(f"Outfit request for {city} with min fashion {fashion}")

    if city == "":
        print(f"City error: city not specified")
        return Response('{"Error": "city not specified"}', status=400, mimetype='application/json')


    if fashion > 10 or fashion < 1:
        print(f"Range error: {fashion} is out of range (1-10)")
        return Response('{"Error": "Fashion level out of range (1-10)"}', status=400, mimetype='application/json')

    return generate_outfit(city, fashion, temperature)


def generate_outfit(city, fashion = fashion_default, temperature = 0):
    coords      = get_city_coord(city)
    temperature = get_today_temperature(coords)


    cold_level = (temperature - max_temperature) / (min_temperature - max_temperature)
    cold_level = abs(cold_level * 9) + 1
    max_warmness = round(cold_level * len(body_parts), 0)
    print(f"Max warmness: {max_warmness}")
    # iterations to prevent death of the whole population giving 0 result (may be removed after optimization)
    for i in range(iterations):
        try:
            population, generations = run_evolution(
                populate_func=partial(
                    generate_population_range, size=population_size, items=body_parts
                ),
                fitness_func=partial(
                    fitness, items=body_parts, max_warmness=max_warmness, min_fashion=fashion
                ),
                mutation_func=partial(
                    mutation, items=body_parts
                ),
                selection_func=selection_pair,
                crossover_func=single_pair_crossover,
                fintess_limit=max_warmness,
                generation_limit=generation_limit,
                logging=False
            )
            print(f"Generations: {generations}")
            result = {
                "target_fashion": fashion,
                "city": city,
                "temperature": {
                    "value": temperature,
                    "unit": "celsius",
                },
                "accuracy": accuracy(population[0], max_warmness, fitness_func=partial(
                    fitness, items=body_parts, max_warmness=max_warmness, min_fashion=fashion
                )),
                "fashion_accuracy": fashion_accuracy(population[0], fashion, body_parts),
                "outfit": solution_to_json(population[0])
            }
            return result
        except ValueError:
            print(f"{i}. ValueError: items pool error")
    print(f"Temperature: {temperature}")
    return Response('{"Error": "E\' molto probabile che i capi di abbigliamento non siano abbastanza bilanciati!"}', status=400, mimetype='application/json')
        


'''
# INSERT
@app.get('/insert')
def get_insert():
    data = {}
    data["name"]        = request.args.get('name', 'untitled')
    data["fashion"]     = request.args.get('fashion', 6)
    data["warmness"]    = request.args.get('warmness', 6)
    data = json.dumps(data)
    return f"{data}"

@app.post('/insert')
def post_insert():
    data = request.get_json()
    data = json.dumps(data)
    return f'{data}'


@app.route('/update', methods=["POST", "GET"])
def modifica():
    return "Qui verranno modificati i vestiti!"
'''
