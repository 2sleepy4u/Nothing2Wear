from random import choices, randint, random, randrange
from utility.logging import progress_bar

def accuracy(item, target, fitness_func):
    fit_value = fitness_func(item)
    return 100 * fit_value / target

def generate_genome_range(items):
    genome = []
    for i, item in enumerate(items):
        genome.append(randrange(len(item)))
    return genome


def generate_population_range(size, items):
    return [generate_genome_range(items) for i in range(size)]

# Selection
def selection_pair(population, fitness_func):
    return choices(
        population=population,
        weights=[fitness_func(genome) for genome in population],
        k=2
    )

# Crossover
def single_pair_crossover(a, b):
    if len(a) < 2:
        return a, b

    length = len(a)
    i = randint(1, length - 1)
    return a[0:i] + b[i:], b[0:i] + a[i:]

# Mutation
def mutation(genome, items, num = 1, probability = 0.5):
    for i in range(num):
        index = randrange(len(genome))
        genome[index] = genome[index] if random() > probability else randrange(len(items[i]))
    return genome

# Fitness
def fitness(genome, items, max_warmness = 70, min_fashion = 6):
    if len(genome) != len(items):
        raise ValueError("Errore nelle lunghezze")
    fashion = 0
    warmness = 0

    for i, b_part in enumerate(items):
        dress_index = genome[i]
        dress = b_part[dress_index]
        warmness += dress.warmness
        fashion += dress.fashion

        if warmness > max_warmness:
            return 0
    
    if fashion / len(genome) < min_fashion:
        return 0

    return warmness


def run_evolution(
    populate_func,
    fitness_func,
    fintess_limit,
    selection_func,
    crossover_func,
    mutation_func,
    generation_limit,
    logging=False
):
    population = populate_func()

    for i in range(generation_limit):
        if logging: progress_bar(i+1, generation_limit, "Calcolando")

        population = sorted(
            population,
            key=lambda genome: fitness_func(genome),
            reverse=True
        )

        if fitness_func(population[0]) >= fintess_limit:
            break

        next_generation = population[0:2]

        for j in range(int(len(population) / 2)):
            parents = selection_func(population, fitness_func)
            offspring_a, offspring_b = crossover_func(parents[0], parents[1])
            offspring_a = mutation_func(offspring_a)
            offspring_b = mutation_func(offspring_b)
            next_generation += [offspring_a, offspring_b]
        
        population = next_generation

    population = sorted(
        population,
        key=lambda genome: fitness_func(genome),
        reverse=True
    )

    print("\r")
    return population, i



