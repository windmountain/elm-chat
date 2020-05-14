port module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Html exposing (Html, button, div, h1, img, text)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)
import Url exposing (Url)



---- PORTS ----


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg



---- MODEL ----


type alias Model =
    { messages : List String
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init f u k =
    ( { messages = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Send
    | Recv String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Send ->
            ( model, sendMessage "aaa" )

        Recv message ->
            ( { model | messages = model.messages ++ [ message ] }, Cmd.none )



---- VIEW ----


viewMessages : List String -> Html Msg
viewMessages messages =
    div []
        (List.map (\m -> div [] [ text m ]) messages)


view : Model -> Browser.Document Msg
view model =
    { title = "Chat"
    , body =
        [ div []
            [ button [ onClick Send ] [ text "Send Message" ]
            , viewMessages model.messages
            ]
        ]
    }



---- ROUTING ----


onUrlRequest : UrlRequest -> Msg
onUrlRequest ur =
    NoOp


onUrlChange : Url -> Msg
onUrlChange url =
    NoOp



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Recv



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }
