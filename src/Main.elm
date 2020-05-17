port module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Element exposing (Element, alignRight, column, el, fill, layout, padding, rgb255, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font
import Element.Input exposing (button, labelAbove, labelHidden, multiline)
import Element.Keyed
import Html exposing (Html, div, h1, img, text, textarea)
import Html.Attributes exposing (src, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Decode.Extra exposing (datetime)
import Time
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { messages : List Message
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
    | ReceiveMessage (Result Decode.Error Message)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Send ->
            ( { model | draft = "" }, sendMessage model.draft )

        Draft message ->
            ( { model | draft = message }, Cmd.none )

        ReceiveMessage result ->
            case result of
                Result.Ok message ->
                    ( { model | messages = model.messages ++ [ message ] }, Cmd.none )

                Result.Err error ->
                    let
                        e =
                            Decode.errorToString error
                    in
                    ( model, Cmd.none )



---- VIEW ----


pusher : Element Msg
pusher =
    Element.paragraph
        [ Element.height <| Element.fillPortion 1
        ]
        [ Element.text "" ]


anchor : Element Msg
anchor =
    Element.paragraph
        [ Element.height <| Element.px 1
        , Element.htmlAttribute <| Html.Attributes.class "ofa-auto"
        ]
        [ Element.text "" ]


messageEl : Message -> Element Msg
messageEl m =
    Element.paragraph [] [ Element.text m.body ]


messageKey : Message -> String
messageKey m =
    m.body ++ (m.time |> Time.posixToMillis |> String.fromInt)


viewMessages : List Message -> Element Msg
viewMessages messages =
    let
        messageEls =
            List.map
                (\m -> ( messageKey m, messageEl m ))
                messages
    in
    Element.Keyed.column
        [ scrollbarY
        , Element.height (Element.fillPortion 2)
        , Element.width Element.fill
        , Element.htmlAttribute <| Html.Attributes.class "children-ofa-none"
        , Background.color (rgb255 255 255 255)
        ]
        (List.concat [ [ ( "p", pusher ) ], messageEls, [ ( "a", anchor ) ] ])



---- EVENT HANDLING ____


type EnterInput
    = Enter
    | ShiftEnter
    | NotEnter


keysToEnterInput : String -> Bool -> EnterInput
keysToEnterInput key shiftKey =
    case key of
        "Enter" ->
            case shiftKey of
                True ->
                    ShiftEnter

                False ->
                    Enter

        _ ->
            NotEnter


enterInputToHandler : msg -> msg -> EnterInput -> ( msg, Bool )
enterInputToHandler enterMsg noOpMsg enterInput =
    -- Bool in (msg, Bool) represents whether to preventDefault.
    -- Default is prevented only on enter, otherwise you get a newline
    -- when you didn't want one
    case enterInput of
        Enter ->
            ( enterMsg, True )

        ShiftEnter ->
            ( noOpMsg, False )

        NotEnter ->
            ( noOpMsg, False )


onKeydown : msg -> msg -> Element.Attribute msg
onKeydown msg msg2 =
    -- Keyup does not work because it create's a flicker of a newline
    Element.htmlAttribute
        (Html.Events.preventDefaultOn "keydown"
            (Decode.map (enterInputToHandler msg msg2)
                (Decode.map2
                    keysToEnterInput
                    (Decode.field "key" Decode.string)
                    (Decode.field "shiftKey" Decode.bool)
                )
            )
        )


view : Model -> Browser.Document Msg
view model =
    { title = "elm-chat"
    , body =
        [ layout
            [ Background.color (rgb255 200 200 200)
            , Element.height fill
            ]
            (column [ Element.height fill, width fill, padding 40, spacing 40 ]
                [ viewMessages model.messages
                , multiline
                    [ onKeydown Send NoOp
                    ]
                    { label = labelHidden "New Message"
                    , onChange = Draft
                    , placeholder = Nothing
                    , spellcheck = False
                    , text = model.draft
                    }
                , Element.Input.button
                    [ Background.color (rgb255 0 128 128)
                    , padding 20
                    , alignRight
                    , Element.Font.color (rgb255 255 255 255)
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



---- DECODERS ----


type alias Message =
    { body : String
    , time : Time.Posix
    }


messageDecoder : Decode.Decoder Message
messageDecoder =
    Decode.map2 Message
        (Decode.field "body" Decode.string)
        (Decode.field "created_at" datetime)



---- PORTS ----


port sendMessage : String -> Cmd msg


port messageReceiver : (Decode.Value -> msg) -> Sub msg



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver (Decode.decodeValue messageDecoder >> ReceiveMessage)



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
