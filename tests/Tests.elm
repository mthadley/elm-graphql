module Tests exposing (..)

import Expect
import GraphqElm.Field as Field exposing (FieldDecoder)
import Json.Decode as Decode exposing (Decoder)
import Schema.MenuItem as MenuItem
import Schema.Query as Query
import Test exposing (..)


type alias MenuItem =
    { name : String }


menusQuery : FieldDecoder (List MenuItem)
menusQuery =
    MenuItem.menuItem MenuItem
        |> Field.with MenuItem.name
        |> Query.menuItems


all : Test
all =
    describe "GraphqElm"
        [ test "generate menu query" <|
            \_ ->
                Field.fieldDecoderToQuery menusQuery
                    |> Expect.equal
                        """{
menuItems {
name
}
}"""
        , test "decodes menu items" <|
            \() ->
                """
                {
  "data": {
  "menuItems": [
  {
  "name": "Masala Chai"
  },
  {
  "name": "Vanilla Milkshake"
  },
  {
  "name": "Chocolate Milkshake"
  }
  ] } }"""
                    |> Decode.decodeString menusDecoder
                    |> Expect.equal
                        (Ok [ { name = "Masala Chai" }, { name = "Vanilla Milkshake" }, { name = "Chocolate Milkshake" } ])
        ]


menusDecoder : Decoder (List MenuItem)
menusDecoder =
    Field.decoder menusQuery



-- menusDecoder : Decoder (List MenuItem)
-- menusDecoder =
--     Decode.at [ "data", "menuItems" ]
--         (Decode.list
--             (Decode.map MenuItem
--                 (Decode.field "name" Decode.string)
--             )
--         )
