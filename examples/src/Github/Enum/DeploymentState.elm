-- Do not manually edit this file, it was auto-generated by Graphqelm
-- npm package version 1.0.0
-- Target elm package version 4.0.0
-- https://github.com/dillonkearns/graphqelm


module Github.Enum.DeploymentState exposing (..)

import Json.Decode as Decode exposing (Decoder)


{-| The possible states in which a deployment can be.

  - Abandoned - The pending deployment was not updated after 30 minutes.
  - Active - The deployment is currently active.
  - Destroyed - An inactive transient deployment.
  - Error - The deployment experienced an error.
  - Failure - The deployment has failed.
  - Inactive - The deployment is inactive.
  - Pending - The deployment is pending.

-}
type DeploymentState
    = Abandoned
    | Active
    | Destroyed
    | Error
    | Failure
    | Inactive
    | Pending


decoder : Decoder DeploymentState
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "ABANDONED" ->
                        Decode.succeed Abandoned

                    "ACTIVE" ->
                        Decode.succeed Active

                    "DESTROYED" ->
                        Decode.succeed Destroyed

                    "ERROR" ->
                        Decode.succeed Error

                    "FAILURE" ->
                        Decode.succeed Failure

                    "INACTIVE" ->
                        Decode.succeed Inactive

                    "PENDING" ->
                        Decode.succeed Pending

                    _ ->
                        Decode.fail ("Invalid DeploymentState type, " ++ string ++ " try re-running the graphqelm CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : DeploymentState -> String
toString enum =
    case enum of
        Abandoned ->
            "ABANDONED"

        Active ->
            "ACTIVE"

        Destroyed ->
            "DESTROYED"

        Error ->
            "ERROR"

        Failure ->
            "FAILURE"

        Inactive ->
            "INACTIVE"

        Pending ->
            "PENDING"
