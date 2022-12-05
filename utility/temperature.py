import requests
from datetime import date
import numpy as np

#Coord = namedtuple("Coord", ["name", "lat", "long"])
#Trieste = Coord("Trieste", 45.65, 13.78)

def get_today_temperature(coord):
    today = date.today()
    url = 'https://api.open-meteo.com/v1/forecast'
    params = {
        "latitude": coord["lat"],
        "longitude": coord["long"],
        "hourly": "temperature_2m",
        "start_date": today,
        "end_date": today
    }
    result = requests.get(url, params=params).json()
    temperature = round(np.mean(result["hourly"]["temperature_2m"]), 1)
    return temperature

