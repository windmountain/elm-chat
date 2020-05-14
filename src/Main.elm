port module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Html exposing (Html, button, div, h1, img, text, textarea)
import Html.Attributes exposing (src, value)
import Html.Events exposing (onClick, onInput)
import Url exposing (Url)



---- PORTS ----


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg



---- MODEL ----


type alias Model =
    { messages : List String
    , draft : String
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init f u k =
    ( { messages = []
      , draft = ""
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | Draft String
    | Send
    | Recv String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Send ->
            ( { model | draft = "" }, sendMessage model.draft )

        Recv message ->
            ( { model | messages = model.messages ++ [ message ] }, Cmd.none )

        Draft message ->
            ( { model | draft = message }, Cmd.none )



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
            [ textarea [ onInput Draft, value model.draft ] []
            , button [ onClick Send ] [ text "Send Message" ]
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
