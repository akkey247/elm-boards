module Page.Show exposing (Model, Msg, init, subscriptions, update, view)

import Route
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Env exposing (Env)
import Threads exposing (..)
import PageCommon exposing (..)



-- MODEL


type alias Model =
    { env : Env
    , id : Int
    , responseThread : PageState Thread
    , navState : Navbar.State
    }


init : Env -> Int -> ( Model, Cmd Msg )
init env id =
    let
        responseThread = Loading
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
    in
        ( Model env id responseThread navState
        , navCmd
        )



-- UPDATE


type Msg
    = NavMsg Navbar.State
    | GotThread (Result Http.Error Thread)


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
                    ( { model | responseThread = Success thread }, Cmd.none )

                Err error ->
                    ( { model | responseThread = Failure error }, Cmd.none )



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
                [
                    case model.responseThread of
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
                    [ Button.danger, Button.attrs [ Spacing.ml1 ] ]
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
                [ Spinner.small, Spinner.attrs [ Spacing.mr3 ] ] []
            , text "Loading..."
            ]
        ]
