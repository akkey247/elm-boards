module Page.Index exposing (Model, Msg, init, subscriptions, update, view)

import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Button as Button
import Bootstrap.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import Env exposing (Env)
import Id exposing (Id)
import Json.Decode as JD
import Route



-- MODEL


type alias Model =
    { env : Env
    , items : List Item
    , navState : Navbar.State
    }


type alias Item =
    { id : Id
    , name : String
    }


init : Env -> ( Model, Cmd Msg )
init env =
    let
        items =
            List.range 1 5
                |> List.map (\i -> "item" ++ String.fromInt i)
                |> List.map (\name -> ( JD.decodeString Id.idDecoder ("\"" ++ name ++ "\""), name ))
                |> List.filterMap
                    (\result ->
                        case Tuple.first result of
                            Ok id ->
                                Just <| Item id (Tuple.second result)

                            _ ->
                                Nothing
                    )
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
    in
        ( Model env items navState
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
    { title = "elm-my-app - index"
    , body =
        [ CDN.stylesheet
        , Grid.container []
            [ menu model
            , viewTable model.items
            ]
        ]
    }

menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [] [ text "Index" ]
        |> Navbar.customItems
            [ Navbar.textItem []
                [
                    Button.linkButton
                        [ Button.outlineDark, Button.attrs [ Route.href Route.New ] ]
                        [ text "New" ]
                ]
            ]
        |> Navbar.view model.navState

viewTable : List Item -> Html Msg
viewTable items =
    Table.table
        { options = [ Table.striped, Table.hover ]
        , thead =
            Table.simpleThead
                [ Table.th [] [ text "id" ]
                , Table.th [] [ text "name" ]
                , Table.th [] [ text "" ]
                ]
        , tbody =
            Table.tbody [] (List.map viewTr items)
        }

viewTr : Item -> Table.Row Msg
viewTr item =
    Table.tr []
        [ Table.td [] [ text (Id.toString item.id) ]
        , Table.td [] [ text item.name ]
        , Table.td [ Table.cellAttr (class "text-right") ] [ Button.linkButton [ Button.outlineDark, Button.small, Button.attrs [ Route.href <| Route.Show item.id ] ] [ text "Show" ] ]
        ]
