module Generate exposing (..)
import Outfit exposing(..)
import Browser
import Html exposing (Html, Attribute, button, div, text, span, input, form, a, label)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Attributes exposing (class, placeholder, href, value, type_, min, id, max)
import Http
import Debug exposing (toString)
import Json.Decode exposing (Decoder, at, map2, field, float, index, string, map7)
import Json.Encode
import Stat
import Json.Encode exposing (object)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html.Attributes exposing (for)


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
    Grid.container [] [
        Form.form [] [
            Form.group [] [
                Form.label [ for "city"] [ text "Città"],
                Input.text [ Input.id "city", Input.value model.city, Input.onInput ChangeCity]
            ],
            Form.group [] [
                Form.label [ for "fashion"] [ text "Stile"],
                Input.number [ Input.id "fashion", Input.value (String.fromInt model.fashion), Input.onInput ChangeFashion]
            ]
        ]
    ]


view_: Model -> Html Msg
view_ model = 
    form [ class "container form-horizontal", onSubmit ( Geocode model.city)] [
        div [ class "form-group"] [
            div [ class "row text-center" ] [
                a [ href "/" , class "col-6"] [ text "Home" ],
                a [ href "/form/correct",  class "col-6" ] [ text "Correggi" ]
            ],
            div [ class "text-center mt-3"] [
                input [ value model.city, onInput ChangeCity, placeholder "Città", class "col-12 form-control "] [],
                label [ for "Fashion", class "form-label" ] [ text ("Fashion: " ++ ( String.fromInt model.fashion )) ],
                input [ value (String.fromInt model.fashion), onInput ChangeFashion, 
                        placeholder "Livello fashion", class "col-12 form-control form-range", id "Fashion", Html.Attributes.min "1", Html.Attributes.max "5", type_ "range" ] []
            ],
            div [ class "text-center mt-3"] [
                button [ class "btn btn-primary" ] [ text "Genera"]
            ]
        ],
        span [] [ text (outfitToString model.outfit) ]
    ]

outfitAPI = "https://2sleepy.pythonanywhere.com/generate"

type alias Coords = {
    latitude: Float,
    longitude: Float
    }


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