from utility.vestiti import body_parts, class_names

def suggestion_log(population):
    pieces = ""
    for i, dress in enumerate(population[0]):
        pice = body_parts[i][dress]
        pieces += f"<b>{class_names[i]}:</b> {pice.name} <br>"
    return pieces

def solution_to_json(solution):
    result = {}
    for i, dress in enumerate(solution):
        piece = body_parts[i][dress]
        result[class_names[i]] = piece.name
    return result

def progress_bar(progress, total, caption="Progress"):
    percent = 100 * (progress / float(total))
    bar = '*' * int(percent) + '-' * (100 - int(percent))
    print(f"\r{caption}: |{bar}| {percent:.2f}%", end="\r")
