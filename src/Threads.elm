module Threads exposing (..)

import Json.Decode exposing (..)

type alias Thread =
    { id : Int, title : String, content : String }

threadDecoder : Decoder Thread
threadDecoder =
    Json.Decode.map3 Thread
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "content" Json.Decode.string)

threadsDecoder : Decoder (List Thread)
threadsDecoder =
    Json.Decode.list threadDecoder