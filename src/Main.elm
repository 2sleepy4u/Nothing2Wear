module Main exposing (..)
import Outfit exposing(..)
import Browser
import Html exposing (Html, div, text, a)
import Html.Events exposing (onSubmit)
import Html.Attributes exposing (href)
import Http
import Debug exposing (toString)
import Json.Decode as Decode
import Json.Decode exposing (Decoder, at, field, string, map7)
import Json.Encode
import Json.Encode exposing (object)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Html.Attributes exposing (for)
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.Text as Text
import Bootstrap.Form.Select as Select
import Bootstrap.Alert as Alert
import Html exposing (br)
import List exposing (map2)
import Json.Decode exposing (map)
import Json.Decode exposing (list)
import Json.Decode exposing (int)

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
    outfit: Outfit,
    solution: List Int,
    rating: Int,
    error: String
    }

init: String -> ( Model, Cmd Msg )
init currentDate = ({
    city = "", 
    fashion = 1, 
    temperature = 0, 
    currentDate = currentDate, 
    outfit = initOutfit,
    error = "",
    solution = [],
    rating = 0
    }, Cmd.none)

type Msg
    =  GotOutfit (Result Http.Error (Outfit, List Int))
    | ChangeCity String 
    | ChangeFashion String
    | ChangeRating String
    | Generate
    | Correct


update: Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeCity newCity -> 
            ({ model | city = newCity}, Cmd.none)
        ChangeFashion newFashion ->
            case String.toInt newFashion of
                Just fashion ->
                    ({ model | fashion = fashion}, Cmd.none)
                _ ->
                    (model, Cmd.none)
        ChangeRating newRating ->
            case String.toInt newRating of
                Just rating ->
                    ({model | rating = rating}, Cmd.none)
                _ ->
                    ({model | rating = 0}, Cmd.none)
        Generate ->
            (model, generateOutfit model)
        Correct ->
            (model, correctOutfit model)
        GotOutfit result ->
            case result of 
                Ok res ->
                    ({model | 
                        outfit = Tuple.first res, 
                        solution = Tuple.second res, 
                        error = ""
                    }, Cmd.none)
                Err e ->
                    ({model | outfit = initOutfit, error = "Errore nella generazione dell'outfit. Controlla che il nome della città sia scritto correttamente!"}, Cmd.none)


view: Model -> Html Msg
view model =
    Grid.container [] [
        Grid.row [ ] [
            Grid.col [ Col.textAlign Text.alignXsCenter] [
                a [ href "/"] [ text "Home"]
            ],
            Grid.col [ Col.textAlign Text.alignXsCenter] [
                a [ href "/"] [ text "Info"]
            ]
        ],
        Grid.row [ Row.centerXs] [
            Grid.col [ Col.xs4] [
                text "nothing2wear"
            ]
        ],
        Form.form [ onSubmit Generate] [
            Form.group [] [
                Form.label [ for "city"] [ text "Città"],
                Input.text [ Input.id "city", Input.value model.city, Input.onInput ChangeCity]
            ],
            Form.group [] [
                Form.label [ for "fashion"] [ text "Stile"],
                Select.select [ Select.id "fashion", Select.onChange ChangeFashion] [
                    Select.item [] [ text "1"],
                    Select.item [] [ text "2"],
                    Select.item [] [ text "3"],
                    Select.item [] [ text "4"],
                    Select.item [] [ text "5"]
                ]
            ],
            Form.group [] [
                br [] [],
                Grid.row [ Row.centerXs] [
                    Grid.col [ Col.xs4] [
                        Button.button [ Button.primary, Button.block, Button.large ] [ text "Genera"]
                    ]
                ]
            ]    
        ],
        Grid.row [ Row.centerXs] [
            Grid.col [ Col.xs10, Col.textAlign Text.alignXsCenter] [
                outfitToHtml model.outfit
            ]
        ],
        if model.outfit.legs /= "" then 
            Grid.container [] [
                br [] [],
                Form.label [ for "mark"] [ text "Vota! La scala va da 'Ho avuto un sacco di freddo' a 'Ho avuto un saccodi caldo'; lo zero significa che l'outfit andava bene"],
                Select.select [ Select.id "mark", Select.onChange ChangeRating] [
                    Select.item [] [ text "-2"],
                    Select.item [] [ text "-1"],
                    Select.item [] [ text "0"],
                    Select.item [] [ text "1"],
                    Select.item [] [ text "2"]
                ],
                br [] [],
                Grid.row [ Row.centerXs] [
                    Grid.col [ Col.xs4] [
                        Button.button [ Button.primary, Button.block, Button.large, Button.onClick Correct ] [ text "Valuta"]
                    ]
                ]
        ] else if model.error /= "" then
            Alert.simpleDanger  []  [ text model.error]
        else div [] []
    ]



-- HTTP API CALLS

outfitAPI = "http://127.0.0.1:5000/generateFromName"
correctAPI = "http://127.0.0.1:5000/correct"
generateOutfit: Model -> Cmd Msg
generateOutfit model = 
    Http.post {
        url = outfitAPI,
        body = Http.jsonBody (object [
            ("city", Json.Encode.string model.city), 
            ("fashion", Json.Encode.int model.fashion)
            ]),
        expect = Http.expectJson GotOutfit outfitDecoder 
    }

correctOutfit: Model -> Cmd Msg
correctOutfit model = 
    Http.post {
        url = correctAPI,
        body = Http.jsonBody (object [
            ("solution", Json.Encode.list Json.Encode.int model.solution), 
            ("rating", Json.Encode.int model.rating)
            ]),
        expect = Http.expectJson GotOutfit outfitDecoder 
    }

-- JSON DECODERS

outfitDecoder: Decoder (Outfit, List Int)
outfitDecoder = 
    Decode.map2 Tuple.pair 
        (at ["outfit"] (
            map7 Outfit 
            (field "Testa" string)
            (field "Torso, primo strato" string)
            (field "Torso, secondo strato" string)
            (field "Torso, terzo strato" string)
            (field "Gambe" string)
            (field "Calze e calzini" string)
            (field "Scarpe" string)
        ))
        (at ["solution"] (
            list int
        ))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none