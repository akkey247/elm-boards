module Page.Show exposing (Model, Msg, init, subscriptions, update, view)

import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (..)
import Html.Attributes exposing (..)
import Env exposing (Env)
import Route



-- MODEL


type alias Model =
    { env : Env
    , id : Int
    , navState : Navbar.State
    }


init : Env -> Int -> ( Model, Cmd Msg )
init env id =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
    in
        ( Model env id navState
        , navCmd
        )



-- UPDATE


type Msg
    = NavMsg Navbar.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg state ->
            ( { model | navState = state }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg



-- VIEW


view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "elm-my-app - show"
    , body =
        [ CDN.stylesheet
        , Grid.container []
            [ menu model
            , article [ Spacing.mt2 ]
                [ Card.config []
                |> Card.block []
                    [ Block.titleH4 [] [ text "Title" ]
                    , Block.text [] [ text "Content" ]
                    ]
                |> Card.view
                ]
            ]
        ]
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
