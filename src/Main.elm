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
import Task
import Time exposing (Zone)
import Time.Format
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { messages : List Message
    , draft : String
    , zone : Maybe Time.Zone
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init f u k =
    ( { messages = []
      , draft = ""
      , zone = Nothing
      }
    , Task.perform AdjustTimeZone Time.here
    )



---- UPDATE ----


type Msg
    = NoOp
    | Draft String
    | Send
    | ReceiveMessage (Result Decode.Error Message)
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Send ->
            ( { model | draft = "" }, sendMessage model.draft )

        Draft message ->
            ( { model | draft = message }, Cmd.none )

        AdjustTimeZone zone ->
            ( { model | zone = Just zone }, Cmd.none )

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


avatarSize : Int
avatarSize =
    50


avatar : String -> Element Msg
avatar from =
    let
        src =
            if from == "You" then
                "99AA66"

            else
                "FF00FF"
    in
    Element.image
        [ Element.height <| Element.px avatarSize
        , Element.width <| Element.px avatarSize
        , Element.alignTop
        ]
        { src = "https://via.placeholder.com/150/" ++ src
        , description = ""
        }


format : Maybe Time.Zone -> Time.Posix -> String
format maybeZone time =
    case maybeZone of
        Just zone ->
            Time.Format.format zone "padHour:padMinute " <| Time.posixToMillis time

        Nothing ->
            ""


messageView : Maybe Time.Zone -> Message -> Element Msg
messageView maybeZone m =
    let
        time =
            format maybeZone m.time
    in
    Element.row
        [ Element.paddingEach
            { top = 1
            , right = 10
            , bottom = 9
            , left = 10
            }
        , Element.spacing 10
        ]
        [ avatar m.from
        , Element.column [ Element.alignTop, Element.width <| Element.fill, Element.padding 0 ]
            [ Element.row [ Element.spacing 10 ]
                [ Element.el [ Element.Font.bold ] (Element.text <| m.from)
                , Element.el [] (Element.text <| time)
                ]
            , Element.paragraph [] [ Element.text m.body ]
            ]
        ]


messageKey : Message -> String
messageKey m =
    m.from ++ (m.time |> Time.posixToMillis |> String.fromInt)


messagesView : Maybe Time.Zone -> List Message -> Element Msg
messagesView zone messages =
    let
        messageEls =
            List.map
                (\m -> ( messageKey m, messageView zone m ))
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
                [ messagesView model.zone model.messages
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
    , from : String
    }


messageDecoder : Decode.Decoder Message
messageDecoder =
    Decode.map3 Message
        (Decode.field "body" Decode.string)
        (Decode.field "created_at" datetime)
        (Decode.field "from" Decode.string)



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
