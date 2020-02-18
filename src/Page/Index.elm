module Page.Index exposing (Model, Msg, init, subscriptions, update, view)

import Route
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table
import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Env exposing (Env)
import Threads exposing (..)
import PageCommon exposing (..)


-- MODEL

type alias Model =
    { env : Env
    , threads : List Thread
    , pageState : PageState
    , navState : Navbar.State
    }

init : Env -> ( Model, Cmd Msg )
init env =
    let
        threads = [ Thread 0 "" "" ]
        pageState = Loading
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
    in
        ( Model env threads pageState navState
        , navCmd
        )


-- UPDATE

type Msg
    = NavMsg Navbar.State
    | GotThreads (Result Http.Error (List Thread))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg state ->
            ( { model | navState = state }
            , case model.pageState of
                Loading ->
                    getThreads

                _ ->
                    Cmd.none
            )

        GotThreads result ->
            case result of
                Ok threads ->
                    ( { model | pageState = Success, threads = threads }, Cmd.none )

                Err _ ->
                    ( { model | pageState = Failure }, Cmd.none )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


-- VIEW

view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "Index"
    , body =
        [ CDN.stylesheet
        , Grid.container []
            [ viewNavbar model
            , section [ Spacing.mt4 ] [
                case model.pageState of
                    Loading ->
                        viewLoading

                    Success ->
                        viewThreadList model.threads

                    Failure ->
                        text "Failed..."
                ]
            ]
        ]
    }


-- User-Defined Functions

getThreads : Cmd Msg
getThreads =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" ("Bearer " ++ "jwt")
            , Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "https://api.myjson.com/bins/1d0bpo"
        , expect = Http.expectJson GotThreads threadsDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }

viewNavbar : Model -> Html Msg
viewNavbar model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [] [ text "Index" ]
        |> Navbar.customItems
            [ Navbar.textItem []
                [ Button.linkButton
                    [ Button.outlineDark, Button.attrs [ Route.href Route.New ] ]
                    [ text "New" ]
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

viewThreadList : List Thread -> Html Msg
viewThreadList threads =
    Table.table
        { options = [ Table.striped, Table.hover ]
        , thead =
            Table.simpleThead
                [ Table.th [] [ text "Id" ]
                , Table.th [] [ text "Title" ]
                , Table.th [] [ text "" ]
                ]
        , tbody =
            Table.tbody [] (List.map viewThreadItem threads)
        }

viewThreadItem : Thread -> Table.Row Msg
viewThreadItem thread =
    Table.tr []
        [ Table.td [] [ text <| String.fromInt thread.id ]
        , Table.td [] [ text thread.title ]
        , Table.td [ Table.cellAttr (class "text-right") ] [ Button.linkButton [ Button.outlineDark, Button.small, Button.attrs [ Route.href <| Route.Show thread.id ] ] [ text "Show" ] ]
        ]
