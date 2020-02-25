module Page.Show exposing (Model, Msg, init, subscriptions, update, view)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Env exposing (Env)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import PageCommon exposing (..)
import Route



-- MODEL


type alias Model =
    { env : Env
    , id : Int
    , responseThread : ApiResponse Thread
    , responseDelete : ApiResponse DeleteResult
    , navState : Navbar.State
    , modalVisibility : Modal.Visibility
    }


init : Env -> Int -> ( Model, Cmd Msg )
init env id =
    let
        responseThread =
            Loading

        responseDelete =
            NotAsked

        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        modalVisibility =
            Modal.hidden
    in
    ( Model env id responseThread responseDelete navState modalVisibility
    , navCmd
    )



-- UPDATE


type Msg
    = NavMsg Navbar.State
    | GotThread (Result Http.Error Thread)
    | Delete
    | Deleted (Result Http.Error DeleteResult)
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
                    ( { model | responseThread = Success thread }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | responseThread = Failure error }
                    , Cmd.none
                    )

        Delete ->
            ( { model | responseDelete = Loading }
            , case model.responseThread of
                Success thread ->
                    deleteThread thread.id

                _ ->
                    Cmd.none
            )

        Deleted result ->
            case result of
                Ok deleteResult ->
                    ( { model | responseDelete = Success deleteResult, modalVisibility = Modal.shown }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | responseDelete = Failure error }
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
    { title = "Show"
    , body =
        [ CDN.stylesheet
        , Grid.container []
            [ menu model
            , article [ Spacing.mt2 ]
                [ case model.responseThread of
                    Loading ->
                        viewLoading

                    Success thread ->
                        Card.config []
                            |> Card.block []
                                [ Block.titleH4 [] [ text thread.title ]
                                , Block.text [] [ text thread.content ]
                                ]
                            |> Card.view

                    _ ->
                        viewLoading
                ]
            ]
        , Modal.config CloseModal
            |> Modal.small
            |> Modal.hideOnBackdropClick True
            |> Modal.h3 [] [ text "Message" ]
            |> Modal.body []
                [ p []
                    [ case model.responseDelete of
                        Failure _ ->
                            text "Failed..."

                        Success deleteResult ->
                            text deleteResult.status

                        Loading ->
                            text "loading..."

                        NotAsked ->
                            text "not asked"
                    ]
                ]
            |> Modal.footer []
                [ Button.linkButton
                    [ Button.outlinePrimary
                    , Button.attrs [ Route.href Route.Index ]
                    ]
                    [ text "OK" ]
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
        , url = "http://127.0.0.1:8000/api/boards/" ++ String.fromInt id
        , expect = Http.expectJson GotThread threadDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


deleteThread : Int -> Cmd Msg
deleteThread id =
    Http.request
        { method = "DELETE"
        , headers =
            [ Http.header "Authorization" ("Bearer " ++ "jwt")
            , Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://127.0.0.1:8000/api/boards/" ++ String.fromInt id
        , expect = Http.expectJson Deleted deleteResultDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [] [ text <| "Show" ]
        |> Navbar.customItems
            [ Navbar.textItem []
                [ Button.linkButton
                    [ Button.primary, Button.attrs [ Route.href <| Route.Edit model.id ] ]
                    [ text "Edit" ]
                , Button.button
                    [ Button.danger, Button.attrs [ Spacing.ml1, onClick Delete ] ]
                    [ text "Delete" ]
                , Button.linkButton
                    [ Button.outlineDark, Button.attrs [ Spacing.ml1, Route.href Route.Index ] ]
                    [ text "Back" ]
                ]
            ]
        |> Navbar.view model.navState


viewLoading : Html Msg
viewLoading =
    div [ style "text-align" "center" ]
        [ Button.button
            [ Button.primary, Button.disabled True ]
            [ Spinner.spinner
                [ Spinner.small
                , Spinner.attrs [ Spacing.mr3 ]
                ]
                []
            , text "Loading..."
            ]
        ]
