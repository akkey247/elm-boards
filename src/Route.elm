module Route exposing (Route(..), fromUrl, href, parser, routeToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Id exposing (Id)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Index
    | New
    | Show Id
    | Edit Id


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Index (Parser.s "boards")
        , Parser.map New (Parser.s "boards" </> Parser.s "new")
        , Parser.map Show (Parser.s "boards" </> Parser.s "show" </> Id.idParser)
        , Parser.map Edit (Parser.s "boards" </> Parser.s "edit" </> Id.idParser)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Index ->
                    []

                New ->
                    [ "new" ]

                Show id ->
                    [ "show", Id.toString id ]

                Edit id ->
                    [ "edit", Id.toString id ]
    in
    "/boards/" ++ String.join "/" pieces
