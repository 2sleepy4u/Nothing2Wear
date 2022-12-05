from collections import namedtuple

Dress = namedtuple("Dress", ["name", "fashion", "warmness"])

head = [
    Dress("Cappellino bianco", 9, 8),
    Dress("Cappellino mucca", 9, 8),

    Dress("Niente", 4, 1)
]

torso_1 = [
    Dress("Maglia oversize scheletri", 10, 4),
    Dress("Maglia oversize vodoo", 10, 4),
    Dress("Maglia palaye royale", 9, 3),
    Dress("Maglia barcellona holy tatoo wear", 9, 4),
    Dress("Body righe bianche e nere", 9, 2),

    Dress("Niente", 4, 1)

]

torso_2 = [
    Dress("Camicia bianca", 9, 3),
    Dress("Maglione nero scollato a V", 7, 8),
    Dress("Effe", 7, 8),
    Dress("Gilet vest", 10, 4),
    Dress("Salopette nera", 10, 4),
    Dress("Camicetta maniche a sbuffo", 10, 4),
    
    Dress("Niente", 5, 1)

]

torso_3 = [
    Dress("Felpa wargasm", 10, 8),
    Dress("Maglione nero bucato", 9, 6),
    Dress("Maglione stone island", 9, 10),
    Dress("Maglione marrone rotto", 9, 5),
    Dress("Pile beige", 4, 9),
    Dress("Felpa fuck god", 9, 8),
    Dress("Felpa grmbuile con colletto", 9, 8),
    Dress("Giacca grigia", 6, 7),

    Dress("Niente", 5, 1)

]

legs = [
    Dress("Gonna nera", 10, 3),
    Dress("Gonna bianca e nera", 10, 3),
    Dress("Gonna verde", 9, 3),

    Dress("Pantaloni sci", 8, 10),
    Dress("Jeans neri zampa", 10, 7),
    Dress("Pants a righe verticali", 9, 7),
    Dress("Pants a qudri", 8, 7),
    Dress("Pants nuovi gagi", 9, 7),

]

feet_1 = [
    Dress("Calzini qualsiasi", 6, 2),
    Dress("Calzini muccati", 8, 2),
    Dress("Calzetti alti neri", 9, 2),

    Dress("Calze felpate", 8, 9),
    Dress("Antiscivolo verdi", 9, 9)
]

feet_2 = [
    Dress("Vans", 8, 5),
    Dress("Creepers", 10, 7),
    Dress("Anfibi", 10, 9)
]


body_parts = [
    head,
    torso_1,
    torso_2,
    torso_3,
    legs,
    feet_1,
    feet_2
]

class_names = [
    "Testa",
    "Torso, primo strato",
    "Torso, secondo strato",
    "Torso, terzo strato",
    "Gambe",
    "Calze e calzini",
    "Scarpe"
]