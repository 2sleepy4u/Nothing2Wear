module Outfit exposing (..)
import Html exposing (text)
import Html exposing (Html)
import Html exposing (span)
import Html exposing (div)

main =
    text "ciao"

type alias Outfit = {
    head: String,
    torso_1: String,
    torso_2: String,
    torso_3: String,
    legs: String,
    feet_1: String,
    feet_2: String
    }

initOutfit: Outfit
initOutfit = {
    head = "",
    torso_1 = "",
    torso_2 = "",
    torso_3 = "",
    legs = "",
    feet_1 = "",
    feet_2 = ""
    }

outfitToHtml: Outfit -> Html msg
outfitToHtml outfit =
    div [] [
        div [] [ text outfit.head],
        div [] [ text outfit.torso_1],
        div [] [ text outfit.torso_2],
        div [] [ text outfit.torso_3],
        div [] [ text outfit.legs],
        div [] [ text outfit.feet_1],
        div [] [ text outfit.feet_2]
    ]

outfitToString: Outfit -> String
outfitToString outfit =
    outfit.head ++ " - " ++ outfit.torso_1 ++ " - " ++ outfit.torso_2 ++ " - " ++ outfit.torso_3 ++ " - "++ outfit.legs ++ " - " ++ outfit.feet_1 ++ " - " ++ outfit.feet_2
