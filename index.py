from functools import partial
import json
from flask import Flask, request, Response, render_template
from flask_cors import CORS, cross_origin
from utility.files import read_from_file, save_to_file
# custom
from utility.temperature import get_today_temperature
from utility.genetic_algorithm import *
from utility.logging import solution_to_json
#from data.vestiti import body_parts
from utility.geocoding import get_city_coord
from utility.options import *

data_path = "static/data/vestiti.json"

body_parts = read_from_file(data_path)

# app
app = Flask(__name__, static_folder="static", template_folder='templates')
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route('/')
def index():
    return render_template("index.html")

@app.route("/form/correct")
def result():
    return render_template("correct.html")

@app.get('/generate')
@cross_origin()
def get_outfit():
    # Inputs data
    fashion     = int(request.args.get('fashion', -1))
    temperature = int(request.args.get("temperature", -100))
    city        = request.args.get("city", "")

    if fashion == -1:
        print(f"Fashion Error: fashion level not specified")
        return Response('{"Error": "fashion level not specified"}', status=400, mimetype='application/json')

    if fashion > 10 or fashion < 1:
        print(f"Range error: {fashion} is out of range (1-10)")
        return Response('{"Error": "Fashion level out of range (1-10)"}', status=400, mimetype='application/json')

    if temperature <= -100 and city == "":
        return Response('{"Error": "Temperature or city not specified"', status=400, mimetype="application/json")

    return generate_outfit(fashion, temperature)
  
@app.post('/generate')
def post_outfit():
    data = request.get_json()
    data = json.dumps(data)

    fashion     = data["fashion"]
    temperature = data["temperature"]

    if fashion > 10 or fashion < 1:
        print(f"Range error: {fashion} is out of range (1-10)")
        return Response('{"Error": "Fashion level out of range (1-10)"}', status=400, mimetype='application/json')

    return generate_outfit(fashion, temperature)

@app.post("/correct")
def correct():
    data = request.get_json()
    #data = json.loads(data)
    print(data)
    solution = data["solution"]
    # -2 to 2
    rating   = data["rating"]

    error = rating 
    correct = {}
    actual = {}

    for i, part in enumerate(body_parts):
        index = solution[i]
        dress = part[index]

        value = round(dress["warmness"] + learning_rate * error * dress["warmness"], 1)
        value_normalized = max(1, value)
        value_normalized = min(5, value_normalized)

        correct[dress["name"]] = value_normalized
        actual[dress["name"]] = dress["warmness"]

    result = [
        actual,
        correct
    ]

    for i, itm in enumerate(solution):
        name = body_parts[i][itm]["name"]
        body_parts[i][itm]["warmness"] = correct[name]
     
    save_to_file(data_path, body_parts)

    return result  

def generate_outfit(fashion = fashion_default, temperature = 0):
    cold_level = (temperature - max_temperature) / (min_temperature - max_temperature)
    cold_level = abs(cold_level * 4) + 1
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
                "temperature": {
                    "value": temperature,
                    "unit": "celsius",
                },
                "accuracy": accuracy(population[0], max_warmness, fitness_func=partial(
                    fitness, items=body_parts, max_warmness=max_warmness, min_fashion=fashion
                )),
                "fashion_accuracy": fashion_accuracy(population[0], fashion, body_parts),
                "outfit": solution_to_json(population[0]),
                "solution": population[0]
            }
            return result
        except ValueError:
            print(f"{i}. Value error")
    return Response('{"Error": "E\' molto probabile che i capi di abbigliamento non siano abbastanza bilanciati!"}', status=400, mimetype='application/json')
        
