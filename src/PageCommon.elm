module PageCommon exposing (..)

import Http
import Json.Decode as Decode

type PageState a
    = NotAsked
    | Loading
    | Success a
    | Failure Http.Error

type alias ApiResult =
    { result : String
    }

resultDecoder : Decode.Decoder ApiResult
resultDecoder =
    Decode.map ApiResult
        (Decode.field "result" Decode.string)