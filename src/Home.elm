module Home where

import UnionType
import Types

import String
import Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects
import Task
import Css exposing (..)
import Css.Elements as Css
import Css.Namespace exposing (namespace)
import Html.CssHelpers
import ColorScheme exposing (..)


cssNamespace = "homepage"

{ class, classList, id } = Html.CssHelpers.withNamespace cssNamespace


type CssClasses =
  Content | Input | Output | Alias

css =
  (stylesheet << namespace cssNamespace)
    [ Css.body
        [ backgroundColor accent1 ]
    , (.) Content
        [ Css.width (px 960)
        , margin2 zero auto
        ]
    , each [ (.) Input, (.) Output ]
        [ Css.width (pct 40)
        , Css.height (px 500)
        , fontFamily monospace
        ]
    , aliasCss
    ]


viewAllUnions : String -> Html
viewAllUnions union =
    let
        type' =
            UnionType.createUnionType union

        output =
            [ UnionType.createTypeFromString type'
            , UnionType.createDecoder type'
            , UnionType.createEncoder type'
            ]
                |> String.join "\n\n"

    in
        textarea
            [ value <| output
            , class [ Output ]
            ]
            []

viewInput : Signal.Address Action -> String -> Html
viewInput address alias =
    textarea
        [ on "input" targetValue (Signal.message address << UpdateInput)
        , class [ Input ]
        , placeholder "Put a union type here"
        ]
        [ text <| alias ]

viewErrors : Signal.Address Action -> List String -> Html
viewErrors address errors =
    ul
        []
        ((List.map (\error -> li [] [ text error ]) errors))


aliasCss : Css.Snippet
aliasCss =
    (.) Alias
        [ padding2 (px 20) zero
        , children
            [ Css.input
                [ padding (px 10)
                , marginLeft (px 10)
                , Css.width (px 250)
                ]
            ]
        ]


view : Signal.Address Action -> Model -> Html
view address model =
    let
        mainBody =
            [ viewAllUnions model.input
            ]
    in
        div
            [ class [ Content ] ]
            ([ Util.stylesheetLink "./homepage.css"
            , viewInput address model.input
            ]
            ++ mainBody)

type Action
    = UpdateInput String
    | Noop

type alias Model =
    { input : String
    , errors : List String
    }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
    case action of
        Noop ->
            (model, Effects.none)
        UpdateInput input ->
            (
                { model
                    | input = input
                }
                , Effects.none)


model =
    { input = """"""
    , errors = []
    }
