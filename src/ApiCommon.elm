module ApiCommon exposing (..)

import Http
import Json.Decode exposing (..)
import Json.Encode exposing (..)


type ApiResponse a
    = NotAsked
    | Loading
    | Success a
    | Failure Http.Error


type alias Thread =
    { id : Int
    , title : String
    , content : String
    }


threadEncoder : Thread -> Json.Encode.Value
threadEncoder thread =
    let
        attributes =
            [ ( "title", Json.Encode.string thread.title )
            , ( "content", Json.Encode.string thread.content )
            ]
    in
    Json.Encode.object attributes


threadDecoder : Decoder Thread
threadDecoder =
    Json.Decode.map3 Thread
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "content" Json.Decode.string)


threadsDecoder : Decoder (List Thread)
threadsDecoder =
    Json.Decode.list threadDecoder


type alias PostResult =
    { status : String
    , result : Thread
    }


postResultDecoder : Decoder PostResult
postResultDecoder =
    Json.Decode.map2 PostResult
        (Json.Decode.field "status" Json.Decode.string)
        (Json.Decode.field "result" threadDecoder)


type alias DeleteResult =
    { status : String
    }


deleteResultDecoder : Decoder DeleteResult
deleteResultDecoder =
    Json.Decode.map DeleteResult
        (Json.Decode.field "status" Json.Decode.string)
