module Main exposing (Flags, Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toEnv, update, updateWith, view)

import Browser
import Browser.Navigation as Nav
import Env exposing (Env)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Page.Edit as EditPage
import Page.Index as IndexPage
import Page.New as NewPage
import Page.Show as ShowPage
import Route exposing (Route)
import Url


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type Model
    = NotFound Env
    | Index Env IndexPage.Model
    | New Env NewPage.Model
    | Show Env Int ShowPage.Model
    | Edit Env Int EditPage.Model


type alias Flags =
    {}


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    changeRouteTo (Route.fromUrl url)
        (NotFound <|
            Env.create key
        )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotIndexMsg IndexPage.Msg
    | GotNewMsg NewPage.Msg
    | GotShowMsg ShowPage.Msg
    | GotEditMsg EditPage.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        env =
            toEnv model
    in
    case ( message, model ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case Route.fromUrl url of
                        Just _ ->
                            ( model, Nav.pushUrl (Env.navKey env) (Url.toString url) )

                        Nothing ->
                            ( model, Nav.load <| Url.toString url )

                Browser.External href ->
                    if String.length href == 0 then
                        ( model, Cmd.none )

                    else
                        ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotIndexMsg subMsg, Index _ subModel ) ->
            IndexPage.update subMsg subModel
                |> updateWith (Index env) GotIndexMsg

        ( GotNewMsg subMsg, New _ subModel ) ->
            NewPage.update subMsg subModel
                |> updateWith (New env) GotNewMsg

        ( GotShowMsg subMsg, Show _ id subModel ) ->
            ShowPage.update subMsg subModel
                |> updateWith (Show env id) GotShowMsg

        ( GotEditMsg subMsg, Edit _ id subModel ) ->
            EditPage.update subMsg subModel
                |> updateWith (Edit env id) GotEditMsg

        ( _, _ ) ->
            ( model, Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        env =
            toEnv model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound env, Cmd.none )

        Just Route.Index ->
            IndexPage.init env
                |> updateWith (Index env) GotIndexMsg

        Just Route.New ->
            NewPage.init env
                |> updateWith (New env) GotNewMsg

        Just (Route.Show id) ->
            ShowPage.init env id
                |> updateWith (Show env id) GotShowMsg

        Just (Route.Edit id) ->
            EditPage.init env id
                |> updateWith (Edit env id) GotEditMsg


toEnv : Model -> Env
toEnv page =
    case page of
        NotFound env ->
            env

        Index env _ ->
            env

        New env _ ->
            env

        Show env _ _ ->
            env

        Edit env _ _ ->
            env


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Index _ subModel ->
            Sub.map GotIndexMsg (IndexPage.subscriptions subModel)

        New _ subModel ->
            Sub.map GotNewMsg (NewPage.subscriptions subModel)

        Show _ _ subModel ->
            Sub.map GotShowMsg (ShowPage.subscriptions subModel)

        Edit _ _ subModel ->
            Sub.map GotEditMsg (EditPage.subscriptions subModel)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage toMsg { title, body } =
            { title = title, body = List.map (Html.map toMsg) body }
    in
    case model of
        NotFound _ ->
            { title = "Not Found", body = [ text "Not Found" ] }

        Index _ subModel ->
            viewPage GotIndexMsg (IndexPage.view subModel)

        New _ subModel ->
            viewPage GotNewMsg (NewPage.view subModel)

        Show _ _ subModel ->
            viewPage GotShowMsg (ShowPage.view subModel)

        Edit _ _ subModel ->
            viewPage GotEditMsg (EditPage.view subModel)
