module PageCommon exposing (..)

import Http
import Json.Decode as Decode
import Threads exposing (..)

type PageState a
    = NotAsked
    | Loading
    | Success a
    | Failure Http.Error

type alias PostResult =
    { status : String
    , result : Thread
    }

postResultDecoder : Decode.Decoder PostResult
postResultDecoder =
    Decode.map2 PostResult
        (Decode.field "status" Decode.string)
        (Decode.field "result" threadDecoder)

type alias DeleteResult =
    { status : String
    }

deleteResultDecoder : Decode.Decoder DeleteResult
deleteResultDecoder =
    Decode.map DeleteResult
        (Decode.field "status" Decode.string)