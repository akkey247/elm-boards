module Route exposing (Route(..), fromUrl, href, parser, routeToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Index
    | New
    | Show Int
    | Edit Int


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Index (Parser.s "boards")
        , Parser.map New (Parser.s "boards" </> Parser.s "new")
        , Parser.map Show (Parser.s "boards" </> Parser.s "show" </> Parser.int)
        , Parser.map Edit (Parser.s "boards" </> Parser.s "edit" </> Parser.int)
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
                    [ "show", String.fromInt id ]

                Edit id ->
                    [ "edit", String.fromInt id ]
    in
    "/boards/" ++ String.join "/" pieces
