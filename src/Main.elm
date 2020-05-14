port module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Element exposing (Element, alignRight, column, el, fill, layout, padding, rgb255, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button, labelAbove, labelHidden, multiline)
import Html exposing (Html, div, h1, img, text, textarea)
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


viewMessages : List String -> Element Msg
viewMessages messages =
    Element.textColumn
        [ scrollbarY
        , Element.height (Element.fillPortion 2)
        , Element.width Element.fill
        ]
        (List.map (\m -> Element.paragraph [] [ Element.text m ]) messages)


view : Model -> Browser.Document Msg
view model =
    { title = "Chat"
    , body =
        [ layout
            [ Background.color (rgb255 200 100 80)
            , Element.height fill
            ]
            (column [ Element.height fill, width fill, padding 40, spacing 40 ]
                [ viewMessages model.messages
                , multiline []
                    { label = labelHidden "New Message"
                    , onChange = Draft
                    , placeholder = Nothing
                    , spellcheck = False
                    , text = model.draft
                    }
                , Element.Input.button
                    [ Background.color (rgb255 20 20 200)
                    , padding 20
                    , alignRight
                    , Font.color (rgb255 255 255 255)
                    ]
                    { label = Element.text "Send"
                    , onPress = Just Send
                    }
                ]
            )
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
