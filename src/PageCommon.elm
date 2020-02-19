module PageCommon exposing (..)

import Http

type PageState a
    = NotAsked
    | Loading
    | Success a
    | Failure Http.Error

