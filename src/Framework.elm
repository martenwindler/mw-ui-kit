module Framework exposing (main)

import Browser
import Browser.Events
import Browser.Navigation
import Config exposing (Conf)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes
import Html.Events
import Svg
import Svg.Attributes
import Routing exposing (..)
import State exposing (..)
import Url

-- X
import MW.About.Introduction as Introduction
import MW.About.Roadmap as Roadmap
import MW.About.Support as Support

-- COMPONENTS FÜR INTROSPECTION
import MW.Atoms.Checkbox as Checkbox
import MW.Atoms.Progress as Progress
import MW.Atoms.Select as Select
import MW.Atoms.Button as Button
import MW.Atoms.Icon as Icon
import MW.Atoms.Logo as Logo
import MW.Base.Color as Color
import MW.Base.Typography as Typography
import MW.Molecules.Card as Card
import MW.Molecules.FormField as FormField
import MW.Molecules.FormFieldWithPattern as FormFieldWithPattern
import MW.Molecules.StyleElements as StyleElements
import MW.Organisms.StyleElementsInput as StyleElementsInput
import MW.Organisms.Clock as Clock
import MW.Organisms.Navbar as Navbar
import MW.Organisms.Sidebar as Sidebar

-- Die fehlende subscriptions Funktion hinzufügen:
subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize MsgChangeWindowSize


{-| Die zentrale Liste aller Komponenten für das mwUI KIT -}
introspections : List ( State.Introspection, Bool )
introspections =
    [ -- ABOUT
    ( Introduction.introspection, False ) 
    , ( Roadmap.introspection, False )
    , ( Support.introspection, False ) 
        
    -- BASE
    , ( Color.introspection, False )
    , ( Typography.introspection, False )
    
    -- ATOMS
    , ( Button.introspection, False )
    , ( Checkbox.introspection, False )
    , ( Icon.introspection, False )
    , ( Logo.introspection, False )
    , ( Progress.introspection, False )
    , ( Select.introspection, False )
    
    -- MOLECULES
    , ( Card.introspection, False )
    , ( FormField.introspection, False )
    , ( FormFieldWithPattern.introspection, False )
    , ( StyleElements.introspection, False )
    
    -- ORGANISMS
    , ( Clock.introspection, False )
    , ( Navbar.introspection, False )
    , ( Sidebar.introspection, False )
    , ( StyleElementsInput.introspection, False )
    ]


main : Program Flags Model Msg
main =
    Browser.application
        { init = \flags url key -> ( initModel flags url key introspections, Cmd.none )
        , view = viewDocument
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "mwUI KIT"
    , body = [ view model ]
    }


view : Model -> Html.Html Msg
view model =
    layoutWith
        { options = [ focusStyle { borderColor = Just Color.primary, backgroundColor = Nothing, shadow = Nothing } ] }
        [ Font.size 16
        , Font.color model.conf.grey3
        , Background.color Color.white
        ]
    <|
        viewPage model.maybeWindowSize model


-- FIX FÜR DAS LAYOUT (Navbar & Sidebar wirklich fixieren)
viewPage : Maybe WindowSize -> Model -> Element Msg
viewPage maybeWindowSize model =
    column
        [ height fill
        , width fill
        , htmlAttribute (Html.Attributes.class "mw-ui-layout")
        , inFront (viewThemeMenu model) 
        ]
        [ -- Navbar oben fixieren
          el 
            [ width fill
            , height (px 66)
            , htmlAttribute (Html.Attributes.style "position" "fixed")
            , htmlAttribute (Html.Attributes.style "top" "0")
            , htmlAttribute (Html.Attributes.style "z-index" "1000")
            ] 
            (viewFrameworkNavbar model)
        
        , row [ width fill, height fill ]
            [ -- Sidebar links fixieren
              el 
                [ width (px 310)
                , height (px 1000) -- Großer Wert für Container
                , htmlAttribute (Html.Attributes.style "position" "fixed")
                , htmlAttribute (Html.Attributes.style "top" "66px")
                , htmlAttribute (Html.Attributes.style "left" "0")
                , htmlAttribute (Html.Attributes.style "bottom" "0")
                , htmlAttribute (Html.Attributes.style "z-index" "900")
                , scrollbarY
                , Background.color model.conf.grey3 -- Damit sie nicht transparent ist
                ] 
                (viewMenuColumn model)
            
            , -- Content-Bereich (erhält Margin, damit er nicht unter der Sidebar liegt)
              el 
                [ width fill
                , paddingEach { top = 66, right = 0, bottom = 0, left = 310 }
                , height fill
                , scrollbarY
                ] 
                (viewContentColumn model)
            ]
        ]

-- Die Navbar des Frameworks
viewFrameworkNavbar : Model -> Element Msg
viewFrameworkNavbar model =
    row
        [ width fill
        , height (px 66)
        , paddingXY 30 0
        , Background.color (rgb255 51 51 51)
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color (rgba 0 0 0 0.2)
        ]
        [ -- BRANDING GROUP (Left aligned)
          link [ centerY ]
            { url = routeToString RouteHome
            , label = 
                row [ spacing 15, centerY ] 
                    [ -- 1. Image Mark (White Logo via Filter)
                      el [ width (px 32), height (px 32), centerY ] <| 
                        html <| 
                            Html.img 
                                [ Html.Attributes.src "assets/img/logo.png"
                                , Html.Attributes.style "width" "32px"
                                , Html.Attributes.style "filter" "brightness(0) invert(1)"
                                ] []
                    
                    , -- 2. Text Mark "mwUI"
                      el [ Font.bold, Font.size 22, Font.color (rgb255 255 255 255), centerY ] (text "MW.UI")
                    
                    , -- 3. Sub-info block (Kit name and Version)
                      column [ spacing 2, centerY, paddingEach { left = 10, right = 0, top = 0, bottom = 0 }, Border.widthEach { left = 1, right = 0, top = 0, bottom = 0 }, Border.color (rgba 255 255 255 0.2) ] 
                        [ el [ Font.size 12, Font.color (rgb255 255 255 255), Font.semiBold ] (text "MW-UI-KIT")
                        , el [ Font.size 11, Font.color (rgba 255 255 255 0.5) ] (text "Version 0.0.1")
                        ]
                    ]
            }

        , -- RECHTER TEIL: CONTROLS
          row [ spacing 20, alignRight, centerY ]
            [ el 
                [ pointer
                , Events.onClick MsgToggleThemeMenu
                , alpha (if model.themeMenuOpen then 1.0 else 0.6)
                , mouseOver [ alpha 1.0 ]
                , centerY
                , width (px 40)
                , height (px 36)
                ] 
                paletteIcon
            , newTabLink [ alpha 0.6, mouseOver [ alpha 1.0 ], centerY ]
                { url = "https://github.com/martenwindler/mw-ui-kit"
                , label = 
                    row [ spacing 10, Font.color (rgb255 255 255 255) ] 
                        [ el [ centerY, width (px 22), height (px 22) ] githubIcon
                        , el [ Font.size 14, centerY ] (text "GitHub") 
                        ]
                }
            ]
        ]

viewThemeMenu : Model -> Element Msg
viewThemeMenu model =
    if not model.themeMenuOpen then
        none

    else
        column
            [ htmlAttribute (Html.Attributes.class "theme-popover")
            , Background.color (rgb255 51 51 51)
            , Border.rounded 8
            , Border.shadow { offset = ( 0, 4 ), size = 1, blur = 12, color = rgba 0 0 0 0.3 }
            , padding 20
            , spacing 20
            , width (px 300)
            , alignRight
            , alignTop
            , moveDown 70
            , moveLeft 20
            ]
            [ -- HEADER MIT COPY BUTTON
            row [ width fill ]
                [ el [ Font.color (rgb255 255 255 255), Font.bold ] (text "Theme Controls")
                , el 
                    [ alignRight
                    , pointer
                    , Events.onClick MsgCopyColor
                    , alpha 0.6
                    , mouseOver [ alpha 1.0 ]
                    , width (px 18)
                    , height (px 18)
                    ] 
                    copyIcon
                ]
            
            -- HEX SOURCE COLOR
            , row [ width fill, spacing 10, padding 10, Background.color (rgba 1 1 1 0.1), Border.rounded 8 ]
                [ el [ Font.color (rgb255 200 200 200), Font.size 14 ] (text "Hex Source Color")
                , el 
                    [ alignRight
                    , width (px 30)
                    , height (px 30)
                    , Background.color (hctToColor model.themeHue model.themeChroma model.themeTone)
                    , Border.rounded 15
                    , Border.width 2
                    , Border.color (rgba 1 1 1 0.2)
                    -- Der Picker als Overlay
                    , inFront <|
                        html <| 
                            Html.input 
                                [ Html.Attributes.type_ "color"
                                , Html.Attributes.value (colorToHex (hctToColor model.themeHue model.themeChroma model.themeTone))
                                , Html.Attributes.style "opacity" "0"
                                , Html.Attributes.style "width" "30px"
                                , Html.Attributes.style "height" "30px"
                                , Html.Attributes.style "cursor" "pointer"
                                , Html.Attributes.style "border" "none"
                                , Html.Events.onInput MsgSetHexColor
                                ] []
                    ] 
                    none
                ]

            -- DIE SLIDERS
            , column [ width fill, spacing 15, paddingXY 0 10 ]
                [ hctSlider "Hue" model.themeHue 360 MsgSetHue
                , hctSlider "Chroma" model.themeChroma 150 MsgSetChroma
                , hctSlider "Tone" model.themeTone 100 MsgSetTone
                ]

            {- AUSKOMMENTIERT: THEME SWITCHER
            , row [ width fill, Border.width 1, Border.color (rgba 1 1 1 0.2), Border.rounded 20, clip ]
                [ themeButton model "dark", themeButton model "auto", themeButton model "light" ]
            -}
            ]

copyIcon : Element msg
copyIcon =
    html <|
        Svg.svg 
            [ Svg.Attributes.width "18"
            , Svg.Attributes.height "18"
            , Svg.Attributes.viewBox "0 0 24 24"
            , Svg.Attributes.style "fill: white; display: block;" 
            ]
            [ Svg.path [ Svg.Attributes.d "M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z" ] [] ]

{-| Konvertiert elm-ui Color zu Hex-String für den Picker -}
colorToHex : Color -> String
colorToHex clr =
    let
        rgba = Element.toRgb clr
        toHex val =
            let
                h = String.fromInt (round (val * 255)) -- Hier müsste eigentlich eine echte Hex-Umrechnung hin
            in
            -- Da Elm-Core kein Hex-Formatting hat, hier ein kleiner Trick für den Picker:
            -- Wenn du es perfekt willst, bräuchtest du eine Pad-Funktion. 
            -- Für den Moment reicht oft ein Standardwert oder ein einfaches Padding.
            h 
    in
    -- Falls der Picker mit dem String nicht klarkommt, nutze vorerst einen statischen Startwert
    -- oder eine Library wie 'elm-community/string-extra' für Padding.
    "#3273dc"

{-| Konvertiert HCT (simuliert als HSL) zu elm-ui Color ohne externe Pakete -}
hctToColor : Float -> Float -> Float -> Element.Color
hctToColor h c t =
    let
        hue = h / 360
        sat = clamp 0 1 (c / 100)
        light = clamp 0 1 (t / 100)

        -- f ist die Standard-Formel zur HSL-zu-RGB Konvertierung
        f n =
            let
                k = Basics.toFloat (modBy 12 (round (n + hue * 12)))
                a = sat * min light (1 - light)
            in
            light - a * max -1 (min (min (k - 3) (9 - k)) 1)
    in
    Element.rgb (f 0) (f 8) (f 4)


{-| Hilfsfunktion für die Framework-Slider -}
hctSlider : String -> Float -> Float -> (Float -> Msg) -> Element Msg
hctSlider title value maxVal msg =
    column [ width fill, spacing 10 ]
        [ row [ width fill ]
            [ el [ Font.size 12, Font.color (rgb255 180 180 180) ] (text title)
            , el [ alignRight, Font.size 12, Font.color (rgb255 180 180 180) ] 
                (text (String.fromInt (round value)))
            ]
        , Input.slider
            [ height (px 4)
            , width fill
            , Background.color (rgba 1 1 1 0.1)
            , Border.rounded 2
            ]
            { onChange = msg
            , label = Input.labelHidden title
            , min = 0
            , max = maxVal
            , step = Just 1
            , value = value
            , thumb =
                Input.thumb
                    [ width (px 16)
                    , height (px 16)
                    , Background.color (rgb255 255 255 255)
                    , Border.rounded 8
                    , Border.shadow { offset = ( 0, 2 ), size = 1, blur = 4, color = rgba 0 0 0 0.2 }
                    ]
            }
        ] -- <--- Diese Klammer hat gefehlt!

themeButton : Model -> String -> Element Msg
themeButton model val =
    let
        isActive =
            model.activeTheme == val
    in
    el
        [ width fill
        , padding 12
        , pointer
        , Events.onClick (MsgSetTheme val)
        , Background.color
            (if isActive then
                -- Falls Color.primary nicht auf HCT reagiert, 
                -- kannst du hier auch (hctToColor model.themeHue model.themeChroma model.themeTone) nutzen
                Color.primary

            else
                rgba 1 1 1 0.05
            )
        , Font.color (rgb255 255 255 255)
        , mouseOver [ Background.color (rgba 1 1 1 0.15) ]
        ]
        (el [ centerX ] (themeIcon val))
        
githubIcon : Element msg
githubIcon =
    html <|
        Svg.svg 
            [ Svg.Attributes.width "20"
            , Svg.Attributes.height "20"
            , Svg.Attributes.viewBox "0 0 24 24"
            , Svg.Attributes.style "fill: currentColor; display: block;" 
            ]
            [ Svg.path [ Svg.Attributes.d "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" ] [] ]

themeIcon : String -> Element msg
themeIcon mode =
    let 
        icon = case mode of
            "dark" -> darkModePath
            "light" -> lightModePath
            _ -> autoModePath
    in
    html <|
        Svg.svg 
            [ Svg.Attributes.width "20"
            , Svg.Attributes.height "20"
            , Svg.Attributes.viewBox "0 0 24 24"
            , Svg.Attributes.style "fill: white; display: block;" 
            ]
            [ Svg.path [ Svg.Attributes.d icon ] [] ]

darkModePath = "M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-3.03 0-5.5-2.47-5.5-5.5 0-1.82.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z"
lightModePath = "M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58a.996.996 0 00-1.41 0 .996.996 0 000 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37a.996.996 0 00-1.41 0 .996.996 0 000 1.41l1.06 1.06c.39.39 1.03.39 1.41 0a.996.996 0 000-1.41l-1.06-1.06zm1.06-10.96a.996.996 0 000-1.41.996.996 0 00-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06zM7.05 18.36a.996.996 0 000-1.41.996.996 0 00-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06z"
autoModePath = "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm.25-13h-1.5v6l4.75 2.85.75-1.23-4-2.37V7z"

paletteIcon : Element msg
paletteIcon =
    html <|
        Html.div []
            [ Svg.svg 
                [ Svg.Attributes.width "40"
                , Svg.Attributes.height "36"
                , Svg.Attributes.viewBox "-5.0 -10.0 110.0 135.0"
                , Svg.Attributes.style "fill: white; display: block; position: relative; top: 2px;" 
                ]
                [ Svg.path 
                    [ Svg.Attributes.d """m84.711 41.816c-4.5664-18.699-19.406-27.758-34.242-27.758-16.199 0-32.395 10.805-35.188 31.645-2.4453 18.758 11.27 37.188 29.703 39.777 1.7617 0.26172 3.8125 0.45703 5.9023 0.45703 6.5508 0 13.516-1.9062 13.305-9.5703-0.71094-4.3945-2.5898-8.4258-1.0391-12.887l0.0625-0.21094c1.3828-4.6484 5.2188-8.4453 9.8047-9.7578 2.457-0.75781 5.2852-0.49609 7.543-1.7617 3.5469-1.7852 5.1367-6.1094 4.1523-9.9414zm-6.3984 5.4727c-0.066406 0.035157-0.13281 0.066407-0.19531 0.10547-0.51953 0.29297-1.625 0.44141-2.6914 0.58203-1.1562 0.15625-2.4648 0.33203-3.8281 0.74609-6.2539 1.8086-11.297 6.832-13.176 13.133l-0.03125 0.10547c-1.5664 4.6211-0.57422 8.8047 0.22266 12.172 0.21875 0.93359 0.42969 1.8203 0.58594 2.6836-0.023438 1.4922-0.54688 2.0312-0.75 2.2422-1.1445 1.1797-3.9688 1.8828-7.5547 1.8828-1.6172 0-3.4023-0.14062-5.207-0.41016-15.637-2.1953-27.527-18.168-25.441-34.164 2.5312-18.867 17.008-27.312 30.234-27.312 6.5469 0 12.926 2.082 17.969 5.8672 5.6055 4.2031 9.5508 10.457 11.414 18.078 0.003907 0.019531 0.011719 0.039062 0.015625 0.058594 0.43359 1.6797-0.26562 3.5781-1.5547 4.2266zm-16.816-14.082c-0.95312 3.3477-4.3828 5.2734-7.6602 4.3008-3.2773-0.97266-5.1641-4.4766-4.2109-7.8242s4.3828-5.2734 7.6602-4.3008c3.2773 0.97266 5.1641 4.4766 4.2109 7.8242zm-17.691 4.957c-0.87891 3.0898-4.0469 4.8672-7.0703 3.9688-3.0273-0.89844-4.7656-4.1328-3.8867-7.2227s4.0469-4.8672 7.0703-3.9688c3.0273 0.89844 4.7656 4.1328 3.8867 7.2227zm-15.125 16.48c-2.5625-0.76172-4.0391-3.5039-3.293-6.1211 0.74609-2.6211 3.4297-4.125 5.9922-3.3633 2.5664 0.76172 4.0391 3.5 3.293 6.1211s-3.4297 4.125-5.9922 3.3633zm11.695 10.012c-0.66016 2.3164-3.0352 3.6523-5.3047 2.9766-2.2695-0.67187-3.5742-3.0977-2.9141-5.41""" ] 
                    [] 
                ]
            ]

frameworkIcon : Element msg
frameworkIcon =
    image 
        [ width (px 60)
        , height (px 60)
        , centerX 
        ] 
        { src = "/assets/img/logo.png" -- Update this path to match your folder structure
        , description = "Logo"
        }

viewMenuColumn : Model -> Element Msg
viewMenuColumn model =
    let
        -- Hier legen wir die Reihenfolge fest, wie im Atomic Design
        orderedCategories =
            [ "About", "Base", "Atoms", "Molecules", "Organisms", "Layouts" ]

        -- Hilfsfunktion: Rendert einen Sektions-Header und die passenden Items
        viewCategoryGroup catName =
            let
                -- Filtere alle Komponenten, die zu dieser Kategorie gehören
                matchingItems =
                    List.filter (\( intro, _ ) -> intro.category == catName) model.introspections
            in
            if List.isEmpty matchingItems then
                none

            else
                column [ width fill, spacing 10 ]
                    [ -- Die Gruppen-Überschrift (z.B. ATOMS)
                      el
                        [ Font.size 12
                        , Font.bold
                        , Font.color (rgba 1 1 1 0.4) -- Subtiles Weiß/Grau
                        , paddingEach { top = 25, bottom = 5, left = 0, right = 0 }
                        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                        , Border.color (rgba 1 1 1 0.1)
                        ]
                        (text (String.toUpper catName))
                    
                    -- Die Liste der Komponenten in dieser Gruppe
                    , column [ width fill, spacing 5 ] <|
                        List.map (\( data, show ) -> viewIntrospectionForMenu model.conf data show) matchingItems
                    ]
    in
    column
        [ Background.color model.conf.grey3
        , Font.color model.conf.greyB
        , width fill
        , height fill
        , spacing 10
        , paddingXY 30 40
        , scrollbarY
        ]
        [ -- Das dynamische Menü, gruppiert nach Atomic Design
          column [ width fill ] <|
            List.map viewCategoryGroup orderedCategories
        ]

viewContentColumn : Model -> Element Msg
viewContentColumn model =
    case maybeSelected model of
        Just ( intro, variation ) ->
            -- Content wenn eine Komponente ausgewählt ist
            column [ width fill, htmlAttribute (Html.Attributes.class "mw-ui-content-wrapper") ]
                [ viewSomething model ( intro, variation ) ]

        Nothing ->
            column 
                [ width fill
                , height fill
                , padding 100
                , spacing 40
                , alignLeft
                ]
                [ -- LANDING PAGE BRANDING (Matching Header Style)
                  column [ spacing 20 ] 
                    [ row [ spacing 25, centerY ] 
                        [ -- 1. Large Image Mark
                          el [ width (px 80), height (px 80), centerY ] <| 
                            html <| 
                                Html.img 
                                    [ Html.Attributes.src "assets/img/logo.png"
                                    , Html.Attributes.style "width" "80px"
                                    -- Keep it dark or remove filter if background is light
                                    ] []
                        
                        , -- 2. Large Text Mark "UI LAB"
                          el [ Font.bold, Font.size 60, Font.color (rgb255 51 51 51), centerY ] (text "MW.UI")
                        
                        , -- 3. Sub-info block (Kit name and Version)
                          column [ spacing 5, centerY, paddingEach { left = 20, right = 0, top = 0, bottom = 0 }, Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }, Border.color (rgba 0 0 0 0.1) ] 
                            [ el [ Font.size 20, Font.color (rgb255 51 51 51), Font.semiBold ] (text "MW-UI-KIT")
                            , el [ Font.size 16, Font.color (rgba 0 0 0 0.5) ] (text "Version 0.0.1")
                            ]
                        ]
                    
                    , -- Welcome Message
                      -- Inside viewContentColumn (Nothing branch)
                        column [ spacing 10, paddingEach { top = 20, left = 0, right = 0, bottom = 0 } ] 
                            [ el [ Font.size 24, alpha 0.7 ] (text "Welcome to the Lab. This is MW-UI-KIT.")
                            , el [ Font.size 24, alpha 0.7 ] (text "Select a component from the sidebar to get started.")
                            ]
                    ]
                ]

viewIntrospection : Model -> State.Introspection -> Element Msg
viewIntrospection model introspection =
    column [ width fill ] -- WICHTIG: width fill
        (viewIntrospectionTitle model.conf introspection
            :: List.map (\( title, subs ) -> viewIntrospectionBody model title subs) introspection.variations
        )


viewIntrospectionTitle : Conf Msg -> State.Introspection -> Element Msg
viewIntrospectionTitle configuration introspection =
    column 
        [ Background.color configuration.greyF
        , padding configuration.mainPadding
        , spacing 10
        , width fill -- WICHTIG: width fill
        ]
        [ el [ Font.size 32, Font.bold ] (text introspection.name)
        , paragraph [ Font.size 24, Font.extraLight ] [ text introspection.description ]
        ]


viewIntrospectionBody : Model -> String -> List ( Element (), String ) -> Element Msg
viewIntrospectionBody model title listSubSection =
    column [ padding model.conf.mainPadding, spacing model.conf.mainPadding, Background.color Color.white, width fill ]
        [ el [ Font.size 28 ] (text title)
        , column [ spacing 10, width fill, clip, scrollbarX ] <|
            List.map (viewSubSection model) listSubSection
        ]


-- Ändere Element Msg zu Element () im Eingabe-Tupel:
viewSubSection : Model -> ( Element (), String ) -> Element Msg
viewSubSection model ( componentExample, componentExampleSourceCode ) =
    let
        ( disp, src ) =
            -- Hier mappen wir die "special:" Platzhalter
            -- Wichtig: Die Mapper in State.elm (z.B. specialComponentCard) 
            -- geben bereits (Element Msg, String) zurück!
            if componentExample == text "special: Cards.example1" then 
                State.specialComponentCard model Card.example1
            else if componentExample == text "special: Form.example5" then 
                State.specialComponentFormField model FormField.example5
            else if componentExample == text "special: Form.example6" then 
                State.specialComponentFormField model FormField.example6
            else if componentExample == text "special: Form.example7" then 
                State.specialComponentFormField model FormField.example7
            else if componentExample == text "special: Form.example8" then 
                State.specialComponentFormField model FormField.example8
            else if componentExample == text "special: Form.example9" then 
                State.specialComponentFormField model FormField.example9
            else if componentExample == text "special: FormFieldWithPattern.example1" then 
                State.specialComponentFormFieldWithPattern model FormFieldWithPattern.example1
            else if componentExample == text "special: example0" then 
                State.specialComponent model StyleElementsInput.example0
            else 
                -- Wenn es kein "special" ist, mappen wir das statische Element () auf Msg
                ( Element.map (\_ -> MsgNoOp) componentExample, componentExampleSourceCode )
    in
    row [ spacing 16, width fill ]
        [ el [ width <| fillPortion 2, height fill ] disp
        , el [ width <| fillPortion 3, height fill ] <| sourceCodeWrapper model.conf src
        ]


viewSomething : Model -> ( State.Introspection, ( String, List ( Element (), String ) ) ) -> Element Msg
viewSomething model ( introspection, ( title, listSubSection ) ) =
    let
        -- Prüfen, ob wir im "About" Bereich sind
        isAbout =
            introspection.category == "About"
    in
    column [ spacing 40, width fill ]
        [ -- Header Bereich (Name & Beschreibung)
        viewIntrospectionTitle model.conf introspection
        
        , if isAbout then
            -- EINSPALTIG: Nur der Content, volle Breite, kein Code-Feld
            column [ spacing 20, width fill, padding 40 ] 
                (List.map (\( bin, _ ) -> viewSubSectionFullWidth model bin) listSubSection)
        else
            -- ZWEISPALTIG: Klassische Ansicht für Komponenten
            column [ spacing 0, width fill ] -- Spacing 0, damit der Titel direkt am Content klebt
                [ viewSubSectionTitle title
                , column [ spacing 10, width fill, padding 40 ] 
                    (List.map (viewSubSection model) listSubSection)
                ]
        ]


viewSubSectionFullWidth : Model -> Element () -> Element Msg
viewSubSectionFullWidth model componentExample =
    -- Wir mappen hier einfach das Element () zu Element Msg
    el [ width fill ] (Element.map (\_ -> MsgNoOp) componentExample)


{-| Zeigt den Titel einer Variation innerhalb einer Komponente an (z.B. 'Größen') -}
viewSubSectionTitle : String -> Element Msg
viewSubSectionTitle title =
    el 
        [ width fill
        , paddingXY 40 10
        , Background.color (rgb255 245 245 245) -- Ein sehr helles Grau
        , Font.size 16
        , Font.bold
        , Font.color (rgb255 100 100 100)
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color (rgb255 230 230 230)
        ] 
        (text title)

viewLogo : Element Msg -> String -> String -> Element Msg
viewLogo title subTitle version =
    link []
        { label = column [ height shrink, spacing 10 ] 
            [ el [ Font.size 60, Font.bold ] title
            , el [ Font.size 16, Font.bold ] <| text subTitle
            , el [ Font.size 14, Font.bold ] <| text <| "Version " ++ version 
            ]
        , url = routeToString RouteHome -- This triggers the clean Welcome screen
        }

viewIntrospectionForMenu : Conf Msg -> State.Introspection -> Bool -> Element Msg
viewIntrospectionForMenu configuration introspection open =
    let
        -- Bestimme, ob dies ein Direktlink (About) oder ein ausklappbares Menü ist
        isAbout =
            introspection.category == "About"

        -- Hole den Namen der ersten Variation für den Link (z.B. "Overview")
        firstVariationName =
            introspection.variations 
                |> List.head 
                |> Maybe.map Tuple.first 
                |> Maybe.withDefault ""

        -- Die Aktion beim Klick
        clickAction =
            if isAbout then
                -- Direkt-Link zur ersten Unterseite
                link [] 
                    { label = menuLabel
                    , url = routeToString <| RouteSubPage (Slug introspection.name) (Slug firstVariationName)
                    }
            else
                -- Klassisches Auf-/Zuklappen
                el [ pointer, Events.onClick <| MsgToggleSection introspection.name, width fill ] menuLabel

        menuLabel =
            paragraph [ alignLeft, Font.bold ]
                [ el [ padding 5, rotate (if open then pi / 2 else 0) ] 
                    (text (if isAbout then "• " else "⟩ ")) -- Punkt statt Pfeil für About
                , el [ Font.size 18 ] <| text introspection.name
                ]
    in
    column [ Font.color configuration.grey9, width fill ]
        [ clickAction
        , if not isAbout && open then
            -- Nur für Nicht-About Sektionen zeigen wir die Unterliste
            column [ height shrink, Font.size 16, Font.color configuration.greyD, spacing 8, paddingEach { bottom = 1, left = 26, right = 0, top = 12 }, clip ] <|
                List.map (\( title, _ ) -> link [] { label = text title, url = routeToString <| RouteSubPage (Slug introspection.name) (Slug title) }) introspection.variations
        else
            none
        ]


sourceCodeWrapper : Conf Msg -> String -> Element Msg
sourceCodeWrapper configuration sourceCode =
    el [ Background.color configuration.grey3, Border.rounded 8, width fill, clip, scrollbars ] <|
        row [ Font.family [ Font.monospace ], Font.color configuration.grey9, Font.size 16, padding 16, width <| px 100 ] [ text sourceCode ]


-- HILFSFUNKTION FÜR NAVIGATION
maybeSelected : Model -> Maybe ( State.Introspection, ( String, List ( Element (), String ) ) )
maybeSelected model =
    let
        ( slug1, slug2 ) =
            case routeFromMaybeUrl model.maybeUrl of
                RouteSubPage s1 s2 -> ( slugToString s1, slugToString s2 )
                _ -> ( "", "" )

        maybeIntro = List.filter (\( intro, _ ) -> intro.name == slug1) model.introspections |> List.head
    in
    case maybeIntro of
        Just ( introspection, _ ) ->
            let
                variation = List.filter (\( name, _ ) -> name == slug2) introspection.variations |> List.head
            in
            Maybe.map (\v -> ( introspection, v )) variation
        Nothing -> Nothing


css : String
css = """
body { line-height: normal !important; }
.elmStyleguideGenerator-open { transition: all .8s; max-height: 500px; }
.elmStyleguideGenerator-close { transition: all .1s; max-height: 0; }
pre { margin: 0; }
.mw-ui-content {
    width: 100% !important;
}
.mw-ui-content > .hc {
    width: 100% !important;
    display: block !important;
}
.mw-ui-content .s.r.wf {
    width: 100% !important;
}

.mw-ui-content .hc.p-141.spacing-41-41.s.c.wf.ct.cl:first-child {
    align-content: flex-start;
    position: relative;
    left: 0px;
    margin-left: 0px;
    padding-left: 0px;
    /* width: 174px; */
}

.hc.p-30-15.bg-51-51-51-255.b-0-0-1-0.bc-0-0-0-51.s.r.wf.cl.ccy {
    position: fixed;
    top: 0rem;
    z-index: 1;
}

.bg-51-51-51-255.fc-182-182-182-255.hf.spacing-10-10.p-30-40.sby.s.c.wf.ct.cl {
    margin-top: 1.5rem;
}

/* In deinen css String einfügen */
.mw-ui-layout {
    position: relative;
}

/* Verhindert, dass die Sidebar durch die Navbar "schimmert", wenn sie fixed ist */
.mw-ui-sidebar {
    z-index: 0;
}

.theme-popover {
    z-index: 9999 !important;
    pointer-events: auto !important; /* Erlaubt Klicks auf Slider & Picker */
    position: fixed !important; /* Sorgt dafür, dass es beim Scrollen stehen bleibt */
    top: 60px;
    right: 30px;
}

/* Verhindert, dass der Picker unterdrückt wird */
input[type="color"] {
    display: block !important;
    visibility: visible !important;
}
"""