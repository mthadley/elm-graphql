module Graphqelm.Generator.Field exposing (generate)

import Graphqelm.Generator.Context exposing (Context)
import Graphqelm.Generator.Decoder
import Graphqelm.Generator.DocComment as DocComment
import Graphqelm.Generator.Imports as Imports
import Graphqelm.Generator.Let as Let exposing (LetBinding)
import Graphqelm.Generator.Normalize as Normalize
import Graphqelm.Generator.OptionalArgs
import Graphqelm.Generator.RequiredArgs
import Graphqelm.Parser.Type as Type exposing (ReferrableType, TypeReference)
import Interpolate exposing (interpolate)


type alias FieldGenerator =
    { annotatedArgs : List AnnotatedArg
    , decoderAnnotation : String
    , decoder : String
    , fieldArgs : List String
    , fieldName : String
    , otherThing : String
    , letBindings : List LetBinding
    , objectDecoderChain : Maybe String
    }


type alias AnnotatedArg =
    { annotation : String
    , arg : String
    }


generate : Context -> String -> Type.Field -> String
generate context thisObjectName field =
    toFieldGenerator context field
        |> forObject_ context thisObjectName field


forObject_ : Context -> String -> Type.Field -> FieldGenerator -> String
forObject_ context thisObjectName field fieldGenerator =
    let
        thisObjectString =
            Imports.object context thisObjectName |> String.join "."
    in
    fieldGeneratorToString (interpolate "FieldDecoder {0} {1}" [ fieldGenerator.decoderAnnotation, thisObjectString ]) field fieldGenerator


fieldGeneratorToString : String -> Type.Field -> FieldGenerator -> String
fieldGeneratorToString returnAnnotation field fieldGenerator =
    let
        something =
            ((fieldGenerator.annotatedArgs |> List.map .annotation)
                ++ [ returnAnnotation ]
            )
                |> String.join " -> "
    in
    interpolate
        """{9}{6} : {3}
{6} {4}={7}
      {5} "{0}" {1} ({2}){8}
"""
        [ fieldGenerator.fieldName
        , fieldGenerator |> fieldArgsString
        , fieldGenerator.decoder
        , something
        , argsListString fieldGenerator
        , "Object" ++ fieldGenerator.otherThing
        , Normalize.fieldName fieldGenerator.fieldName
        , Let.generate fieldGenerator.letBindings
        , fieldGenerator.objectDecoderChain |> Maybe.withDefault ""
        , DocComment.generate field
        ]


argsListString : { fieldGenerator | annotatedArgs : List AnnotatedArg } -> String
argsListString { annotatedArgs } =
    if annotatedArgs == [] then
        ""
    else
        (annotatedArgs |> List.map .arg |> String.join " ") ++ " "


fieldArgsString : { thing | fieldArgs : List String } -> String
fieldArgsString { fieldArgs } =
    case fieldArgs of
        [] ->
            "[]"

        [ single ] ->
            single

        _ ->
            "(" ++ String.join " ++ " fieldArgs ++ ")"


toFieldGenerator : Context -> Type.Field -> FieldGenerator
toFieldGenerator ({ apiSubmodule } as context) field =
    init context field.name field.typeRef
        |> addRequiredArgs apiSubmodule field.args
        |> addOptionalArgs apiSubmodule field.args


addRequiredArgs : List String -> List Type.Arg -> FieldGenerator -> FieldGenerator
addRequiredArgs apiSubmodule args fieldGenerator =
    case Graphqelm.Generator.RequiredArgs.generate apiSubmodule args of
        Just { annotation, list } ->
            { fieldGenerator | fieldArgs = [ list ] }
                |> prependArg
                    { annotation = annotation
                    , arg = "requiredArgs"
                    }

        Nothing ->
            fieldGenerator


addOptionalArgs : List String -> List Type.Arg -> FieldGenerator -> FieldGenerator
addOptionalArgs apiSubmodule args fieldGenerator =
    case Graphqelm.Generator.OptionalArgs.generate apiSubmodule args of
        Just { annotatedArg, letBindings } ->
            { fieldGenerator
                | fieldArgs = "optionalArgs" :: fieldGenerator.fieldArgs
                , letBindings = fieldGenerator.letBindings ++ letBindings
            }
                |> prependArg annotatedArg

        Nothing ->
            fieldGenerator


objectThing : Context -> String -> TypeReference -> String -> FieldGenerator
objectThing ({ apiSubmodule } as context) fieldName typeRef refName =
    let
        objectArgAnnotation =
            interpolate
                "SelectionSet {0} {1}"
                [ fieldName, Imports.object context refName |> String.join "." ]
    in
    { annotatedArgs = []
    , fieldArgs = []
    , decoderAnnotation = Graphqelm.Generator.Decoder.generateType apiSubmodule fieldName typeRef
    , decoder = "object"
    , fieldName = fieldName
    , otherThing = ".selectionFieldDecoder"
    , letBindings = []
    , objectDecoderChain =
        " ("
            ++ (Graphqelm.Generator.Decoder.generateDecoder apiSubmodule typeRef
                    |> String.join " >> "
               )
            ++ ")"
            |> Just
    }
        |> prependArg
            { annotation = objectArgAnnotation
            , arg = "object"
            }


prependArg : AnnotatedArg -> FieldGenerator -> FieldGenerator
prependArg ({ annotation, arg } as annotatedArg) fieldGenerator =
    { fieldGenerator | annotatedArgs = annotatedArg :: fieldGenerator.annotatedArgs }


prependArgs : List AnnotatedArg -> FieldGenerator -> FieldGenerator
prependArgs args fieldGenerator =
    List.foldr prependArg fieldGenerator args


type LeafRef
    = ObjectLeaf String
    | InterfaceLeaf String
    | EnumLeaf
    | ScalarLeaf


leafType : TypeReference -> LeafRef
leafType (Type.TypeReference referrableType isNullable) =
    case referrableType of
        Type.ObjectRef refName ->
            ObjectLeaf refName

        Type.InterfaceRef refName ->
            InterfaceLeaf refName

        Type.Scalar _ ->
            ScalarLeaf

        Type.List nestedReferrableType ->
            leafType nestedReferrableType

        Type.EnumRef _ ->
            EnumLeaf

        Type.InputObjectRef _ ->
            Debug.crash "Unexpected type"


init : Context -> String -> TypeReference -> FieldGenerator
init ({ apiSubmodule } as context) fieldName ((Type.TypeReference referrableType isNullable) as typeRef) =
    case leafType typeRef of
        ObjectLeaf refName ->
            objectThing context fieldName typeRef refName

        InterfaceLeaf refName ->
            objectThing context fieldName typeRef refName

        EnumLeaf ->
            initScalarField apiSubmodule fieldName typeRef

        ScalarLeaf ->
            initScalarField apiSubmodule fieldName typeRef


initScalarField : List String -> String -> TypeReference -> FieldGenerator
initScalarField apiSubmodule fieldName typeRef =
    { annotatedArgs = []
    , fieldArgs = []
    , decoderAnnotation = Graphqelm.Generator.Decoder.generateType apiSubmodule fieldName typeRef
    , decoder =
        Graphqelm.Generator.Decoder.generateDecoder apiSubmodule typeRef
            |> String.join " |> "
    , fieldName = fieldName
    , otherThing = ".fieldDecoder"
    , letBindings = []
    , objectDecoderChain = Nothing
    }
