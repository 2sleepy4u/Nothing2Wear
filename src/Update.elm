module Update exposing (..)
import Outfit exposing (..)
import Html exposing (text)
import Html exposing (Html)


type alias Model = {
    temperature: Float,
    outfit: Outfit  
    }

type Msg =
    Correct

init: (Cmd Msg)
init = ({temperature = 0, outfit = initOutfit}, Cmd.none)

view: Model -> Html Msg
view model =
    text "Ciao"

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of 
        Correct ->
            (model, Cmd.none)