module Generate exposing (..)

import Browser
import Html exposing (Html, button, div, text, span, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Http
import Debug exposing (toString)
import Json.Decode exposing (Decoder, at, map2, field, float, index)
import Json.Decode exposing (string)
import Json.Decode exposing (map7)
import Json.Encode
import Stat
import Json.Encode exposing (object)


main : Program String Model Msg
main =
    Browser.element { 
        init = init, 
        update = update, 
        view = view,
        subscriptions = subscriptions
    }

type alias Model = {
    city: String,
    fashion: Int,
    temperature: Float,
    currentDate: String,
    outfit: Outfit
    }

init: String -> ( Model, Cmd Msg )
init currentDate = ({
    city = "", 
    fashion = 0, 
    temperature = 0, 
    currentDate = currentDate, 
    outfit = initOutfit
    }, Cmd.none)

type Msg
    = GotCoords (Result Http.Error Coords)
    | GotTemperature (Result Http.Error (List Float))
    | GotOutfit (Result Http.Error Outfit)
    | ChangeCity String 
    | ChangeFashion String
    | Geocode String


update: Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Geocode city_name -> 
            (model, geocode city_name)
        ChangeCity newCity -> 
            ({ model | city = newCity}, Cmd.none)
        ChangeFashion newFashion ->
            case String.toInt newFashion of
                Just n ->
                    ({ model | fashion = n}, Cmd.none)
                _ ->
                    (model, Cmd.none)
        GotTemperature result ->
            case result of
                Ok res ->
                    case Stat.mean res of
                        Just temperature ->
                            ({model | temperature = toFloat (round temperature)}, generateOutfit model)
                        _ -> 
                            (model, Cmd.none)
                Err e ->
                    ({model | city = Debug.toString e}, Cmd.none)
        GotCoords result ->
            case result of
                Ok coords ->
                    (model, getTemperature coords model)
                Err e ->
                    ({model | city = Debug.toString e}, Cmd.none)
        GotOutfit result ->
            case result of 
                Ok outfit ->
                    ({model | outfit = outfit}, Cmd.none)
                Err e ->
                    (model, Cmd.none)

view: Model -> Html Msg
view model = 
    div [] [
        input [ value model.city, onInput ChangeCity] [],
        input [ value (String.fromInt model.fashion), onInput ChangeFashion] [],
        button [ onClick ( Geocode model.city) ] [ text "Genera"],
        span [] [ text (outfitToString model.outfit) ]
    ]

outfitAPI = "https://2sleepy.pythonanywhere.com/generate"

type alias Coords = {
    latitude: Float,
    longitude: Float
    }

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


outfitToString: Outfit -> String
outfitToString outfit =
    outfit.head ++ " - " ++ outfit.torso_1 ++ " - " ++ outfit.torso_2 ++ " - " ++ outfit.torso_3 ++ " - "++ outfit.legs ++ " - " ++ outfit.feet_1 ++ " - " ++ outfit.feet_2

-- HTTP API CALLS
geocode : String -> Cmd Msg
geocode city_name =
    Http.get{
        url = "https://geocoding-api.open-meteo.com/v1/search" ++ "?count=1" ++ "&name=" ++ city_name,
        expect = Http.expectJson GotCoords coordsDecoder
    }

getTemperature : Coords -> Model -> Cmd Msg 
getTemperature coords model =
    Http.get{
        url = "https://api.open-meteo.com/v1/forecast" ++ "?hourly=temperature_2m&start_date=" ++ model.currentDate ++ "&end_date=" ++ model.currentDate ++ "&latitude=" ++ String.fromFloat coords.latitude ++ "&longitude=" ++ String.fromFloat coords.longitude,
        expect = Http.expectJson GotTemperature temperatureDecoder
    }

generateOutfit: Model -> Cmd Msg
generateOutfit model =
    Http.get {
        url = outfitAPI ++ "?temperature=" ++ String.fromFloat model.temperature ++ "&fashion=" ++ String.fromInt model.fashion,
        expect = Http.expectJson GotOutfit outfitDecoder
    }

genOutfitPost: Model -> Cmd Msg
genOutfitPost model = 
    Http.post {
        url = outfitAPI,
        body = Http.jsonBody (object [("temperature", Json.Encode.float model.temperature), ("fashion", Json.Encode.int model.fashion)]),
        expect = Http.expectJson GotOutfit outfitDecoder
    }

-- JSON ENCODERS

-- JSON DECODERS

outfitDecoder: Decoder Outfit
outfitDecoder =
    at ["outfit"] (
        map7 Outfit 
        (field "Testa" string)
        (field "Torso, primo strato" string)
        (field "Torso, secondo strato" string)
        (field "Torso, terzo strato" string)
        (field "Gambe" string)
        (field "Calze e calzini" string)
        (field "Scarpe" string)
    )

coordsDecoder: Decoder Coords
coordsDecoder =
    at ["results"] ( index 0 (
        map2 Coords 
        (field "latitude" float)
        (field "longitude" float)
    ))

temperatureDecoder: Decoder (List Float)
temperatureDecoder = 
    at ["hourly"] ( at ["temperature_2m"] (Json.Decode.list float))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none