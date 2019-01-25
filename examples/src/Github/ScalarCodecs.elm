-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Github.ScalarCodecs exposing (Date, DateTime, GitObjectID, GitSSHRemote, GitTimestamp, Html, Id, Uri, X509Certificate, codecs)

import Github.Scalar exposing (defaultCodecs)
import Json.Decode as Decode exposing (Decoder)


type alias Date =
    Github.Scalar.Date


type alias DateTime =
    Github.Scalar.DateTime


type alias GitObjectID =
    Github.Scalar.GitObjectID


type alias GitSSHRemote =
    Github.Scalar.GitSSHRemote


type alias GitTimestamp =
    Github.Scalar.GitTimestamp


type alias Html =
    Github.Scalar.Html


type alias Id =
    Github.Scalar.Id


type alias Uri =
    Github.Scalar.Uri


type alias X509Certificate =
    Github.Scalar.X509Certificate


codecs : Github.Scalar.Codecs Date DateTime GitObjectID GitSSHRemote GitTimestamp Html Id Uri X509Certificate
codecs =
    Github.Scalar.defineCodecs
        { codecDate = defaultCodecs.codecDate
        , codecDateTime = defaultCodecs.codecDateTime
        , codecGitObjectID = defaultCodecs.codecGitObjectID
        , codecGitSSHRemote = defaultCodecs.codecGitSSHRemote
        , codecGitTimestamp = defaultCodecs.codecGitTimestamp
        , codecHtml = defaultCodecs.codecHtml
        , codecId = defaultCodecs.codecId
        , codecUri = defaultCodecs.codecUri
        , codecX509Certificate = defaultCodecs.codecX509Certificate
        }
