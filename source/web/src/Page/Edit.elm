module Page.Edit exposing (Model, Msg, init, subscriptions, update, view)

import ApiCommon exposing (..)
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Bootstrap.Utilities.Spacing as Spacing
import Env exposing (Env)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Route



-- MODEL


type alias Model =
    { env : Env
    , id : Int
    , thread : Thread
    , responseThread : ApiResponse Thread
    , responsePost : ApiResponse PostResult
    , navState : Navbar.State
    , modalVisibility : Modal.Visibility
    }


init : Env -> Int -> ( Model, Cmd Msg )
init env id =
    let
        thread =
            Thread 0 "" ""

        responseThread =
            Loading

        responsePost =
            NotAsked

        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        modalVisibility =
            Modal.hidden
    in
    ( Model env id thread responseThread responsePost navState modalVisibility
    , navCmd
    )



-- UPDATE


type Msg
    = NavMsg Navbar.State
    | GotThread (Result Http.Error Thread)
    | Title String
    | Content String
    | Post
    | Posted (Result Http.Error PostResult)
    | CloseModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg state ->
            ( { model | navState = state }
            , case model.responseThread of
                Loading ->
                    getThreads model.id

                _ ->
                    Cmd.none
            )

        GotThread result ->
            case result of
                Ok thread ->
                    ( { model | responseThread = Success thread, thread = thread }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | responseThread = Failure error }
                    , Cmd.none
                    )

        Title title ->
            ( { model | thread = Thread model.thread.id title model.thread.content }
            , Cmd.none
            )

        Content content ->
            ( { model | thread = Thread model.thread.id model.thread.title content }
            , Cmd.none
            )

        Post ->
            ( { model | responsePost = Loading }
            , postThread model.thread
            )

        Posted result ->
            case result of
                Ok postResult ->
                    ( { model | responsePost = Success postResult, modalVisibility = Modal.shown }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | responsePost = Failure error }
                    , Cmd.none
                    )

        CloseModal ->
            ( { model | modalVisibility = Modal.hidden }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg



-- VIEW


view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "Edit"
    , body =
        [ CDN.stylesheet
        , Grid.container []
            [ menu model
            , article [ Spacing.mt2 ]
                [ Form.form []
                    [ Form.group []
                        [ Form.label [ for "title" ] [ text "Title" ]
                        , Input.text
                            [ Input.id "title"
                            , Input.onInput Title
                            , Input.value model.thread.title
                            ]
                        ]
                    , Form.group []
                        [ Form.label [ for "content" ] [ text "Content" ]
                        , Textarea.textarea
                            [ Textarea.id "content"
                            , Textarea.rows 5
                            , Textarea.onInput Content
                            , Textarea.value model.thread.content
                            ]
                        ]
                    ]
                , div [ class "text-right" ]
                    [ Button.button [ Button.primary, Button.attrs [ onClick Post ] ] [ text "Post" ] ]
                ]
            ]
        , let
            message =
                case model.responsePost of
                    Failure _ ->
                        text "Failed..."

                    Success _ ->
                        text "Success"

                    Loading ->
                        text "loading..."

                    NotAsked ->
                        text "not asked"

            link =
                case model.responsePost of
                    Success postResult ->
                        Route.href <| Route.Show postResult.result.id

                    _ ->
                        href "#"
          in
          Modal.config CloseModal
            |> Modal.small
            |> Modal.hideOnBackdropClick True
            |> Modal.h3 [] [ text "Message" ]
            |> Modal.body [] [ p [] [ message ] ]
            |> Modal.footer []
                [ Button.linkButton
                    [ Button.outlinePrimary
                    , Button.attrs [ link ]
                    ]
                    [ text "Go To Show" ]
                ]
            |> Modal.view model.modalVisibility
        ]
    }



-- User-Defined Functions


getThreads : Int -> Cmd Msg
getThreads id =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" ("Bearer " ++ "jwt")
            , Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://localhost:3000/api/boards/" ++ String.fromInt id
        , expect = Http.expectJson GotThread threadDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


postThread : Thread -> Cmd Msg
postThread thread =
    Http.request
        { method = "PUT"
        , headers =
            [ Http.header "Authorization" ("Bearer " ++ "jwt")
            , Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://localhost:3000/api/boards/" ++ String.fromInt thread.id
        , expect = Http.expectJson Posted postResultDecoder
        , body = Http.jsonBody <| threadEncoder thread
        , timeout = Nothing
        , tracker = Nothing
        }


menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [] [ text <| "Edit" ]
        |> Navbar.customItems
            [ Navbar.textItem []
                [ Button.linkButton
                    [ Button.outlineDark, Button.attrs [ Spacing.ml1, Route.href <| Route.Show model.thread.id ] ]
                    [ text "Go To Show" ]
                ]
            ]
        |> Navbar.view model.navState
