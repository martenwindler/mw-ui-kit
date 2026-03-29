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
import Icons as Icons
import Routing exposing (..)
import State exposing (..)
import Url
import Json.Decode as Decode

-- ABOUT SECTIONS
import MW.About.Introduction as Introduction
import MW.About.Changelog as Changelog
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
import MW.Layouts.LandingLayout as LandingLayout
import MW.Layouts.MainLayout as MainLayout

subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize MsgChangeWindowSize


{-| Die zentrale Liste aller Komponenten für das mwUI KIT -}
introspections : List ( State.Introspection, Bool )
introspections =
    [ -- ABOUT
      ( Introduction.introspection, False ) 
    , ( Changelog.introspection, False )
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

    -- LAYOUTS
    , ( LandingLayout.introspection, False )
    , ( MainLayout.introspection, False )
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
    { title = model.conf.subTitle
    , body = [ view model ]
    }


view : Model -> Html.Html Msg
view model =
    layoutWith
        { options = [ focusStyle { borderColor = Just Color.primary, backgroundColor = Nothing, shadow = Nothing } ] }
        [ Font.size 16
        , Font.color model.conf.grey3
        , Background.color Color.white
        -- Wenn das Menü offen ist, schließt ein Klick auf den Hintergrund das Menü
        , if model.themeMenuOpen then 
            Events.onClick MsgToggleThemeMenu 
          else 
            htmlAttribute (Html.Attributes.class "")
        ]
    <|
        viewPage model.maybeWindowSize model


viewPage : Maybe WindowSize -> Model -> Element Msg
viewPage maybeWindowSize model =
    let
        sidebarWidth = 310
        navbarHeight = 66
        
        currentSidebarWidth =
            if model.sidebarOpen then px sidebarWidth else px 0
        
        contentPaddingLeft =
            if model.sidebarOpen then sidebarWidth else 0
    in
    column
        [ height fill
        , width fill
        , htmlAttribute (Html.Attributes.class "mw-ui-layout")
        , inFront (viewThemeMenu model) 
        ]
        [ -- NAVBAR
          el 
            [ width fill
            , height (px navbarHeight)
            , htmlAttribute (Html.Attributes.style "position" "fixed")
            , htmlAttribute (Html.Attributes.style "top" "0")
            , htmlAttribute (Html.Attributes.style "z-index" "1000")
            ] 
            (viewFrameworkNavbar model)
        
        , row [ width fill, height fill ]
            [ -- SIDEBAR CONTAINER
              el 
                [ width currentSidebarWidth
                -- WICHTIG: Hier berechnen wir die exakte Resthöhe
                , height (fill |> maximum (case maybeWindowSize of
                                            Just ws -> ws.height - navbarHeight
                                            Nothing -> 800)) 
                , htmlAttribute (Html.Attributes.style "position" "fixed")
                , htmlAttribute (Html.Attributes.style "top" (String.fromInt navbarHeight ++ "px"))
                , htmlAttribute (Html.Attributes.style "left" "0")
                , htmlAttribute (Html.Attributes.style "bottom" "0")
                , htmlAttribute (Html.Attributes.style "z-index" "900")
                , htmlAttribute (Html.Attributes.style "transition" "width 0.2s ease-in-out")
                , Background.color model.conf.grey3
                -- Wir verschieben das Scrollen DIREKT hierher
                , scrollbarY 
                , clip 
                ] 
                (viewMenuColumn model)
            
            , -- CONTENT BEREICH
              el 
                [ width fill
                , paddingEach { top = navbarHeight, right = 0, bottom = 0, left = contentPaddingLeft }
                , height fill
                , scrollbarY
                , htmlAttribute (Html.Attributes.style "transition" "padding-left 0.2s ease-in-out")
                ] 
                (viewContentColumn model)
            ]
        ]


viewMenuColumn : Model -> Element Msg
viewMenuColumn model =
    let
        orderedCategories =
            [ "About", "Base", "Atoms", "Molecules", "Organisms", "Layouts" ]

        viewCategoryGroup catName =
            let
                matchingItems =
                    List.filter (\( intro, _ ) -> intro.category == catName) model.introspections
            in
            if List.isEmpty matchingItems then
                none
            else
                column [ width fill, spacing 10 ]
                    [ el
                        [ Font.size 12
                        , Font.bold
                        , Font.color (rgba 1 1 1 0.4)
                        , paddingEach { top = 25, bottom = 5, left = 0, right = 0 }
                        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                        , Border.color (rgba 1 1 1 0.1)
                        ]
                        (text (String.toUpper catName))
                    
                    , column [ width fill, spacing 5 ] <|
                        List.map (\( data, _ ) -> 
                            let
                                isCurrentSection =
                                    case routeFromMaybeUrl model.maybeUrl of
                                        RouteSubPage s1 _ -> slugToString s1 == data.name
                                        _ -> False
                            in
                            viewIntrospectionForMenu model.conf data isCurrentSection
                        ) matchingItems
                    ]
    in
    column
        [ Background.color model.conf.grey3
        , Font.color model.conf.greyB
        , width fill
        , height fill      -- Wichtig: Damit die Sidebar den verfügbaren Platz einnimmt
        , spacing 10
        , paddingXY 30 40
        , scrollbarY       -- Dies aktiviert die vertikale Scrollbar
        ]
        [ column [ width fill ] <|
            List.map viewCategoryGroup orderedCategories
        ]


viewContentColumn : Model -> Element Msg
viewContentColumn model =
    case maybeSelected model of
        Just ( intro, variation ) ->
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
                [ column [ spacing 30, alignLeft ] 
                    [ row [ spacing 25, centerY ] 
                        [ el [ width (px 80), height (px 80), centerY ] <| 
                            html <| Html.img [ Html.Attributes.src "assets/img/logo.png", Html.Attributes.style "width" "80px" ] []
                        
                        , el [ Font.bold, Font.size 60, Font.color (rgb255 51 51 51), centerY ] (text "MW.UI")
                        
                        , column [ spacing 5, centerY, paddingEach { left = 20, right = 0, top = 0, bottom = 0 }, Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }, Border.color (rgba 0 0 0 0.1) ] 
                            [ el [ Font.size 20, Font.color (rgb255 51 51 51), Font.semiBold ] (text "MW-UI-KIT")
                            , el [ Font.size 16, Font.color (rgba 0 0 0 0.5) ] (text ("Version " ++ model.conf.version))
                            ]
                        ]
                    
                    , column [ spacing 12, paddingEach { top = 10, left = 0, right = 0, bottom = 0 }, alignLeft ] 
                        [ el [ Font.size 24, alpha 0.7 ] (text "Welcome to the Lab.")
                        , el [ Font.size 24, alpha 0.7 ] (text "This is MW-UI-KIT.")
                        , el [ Font.size 24, alpha 0.7 ] (text "Select a component from the sidebar to get started.")
                        ]
                    ]
                ]


viewFrameworkNavbar : Model -> Element Msg
viewFrameworkNavbar model =
    row
        [ width fill
        , height (px 66)
        , paddingXY 20 0
        , Background.color (rgb255 51 51 51)
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color (rgba 0 0 0 0.2)
        , Font.color (rgb255 255 255 255) 
        ]
        [ row [ spacing 15, centerY ]
            [ el 
                [ pointer
                , Events.onClick MsgToggleSidebar
                , alpha 0.8
                , mouseOver [ alpha 1.0 ]
                , padding 10
                , Font.color (rgb255 255 255 255)
                ] 
                Icons.hamburger
            
            , link [ centerY ]
                { url = routeToString RouteHome
                , label = 
                    row [ spacing 15, centerY ] 
                        [ el [ width (px 32), height (px 32), centerY ] <| 
                            html <| Html.img [ Html.Attributes.src "assets/img/logo.png", Html.Attributes.style "width" "32px", Html.Attributes.style "filter" "brightness(0) invert(1)" ] []
                        , el [ Font.bold, Font.size 22, centerY ] (text model.conf.brandName)
                        , column [ spacing 2, centerY, paddingEach { left = 10, right = 0, top = 0, bottom = 0 }, Border.widthEach { left = 1, right = 0, top = 0, bottom = 0 }, Border.color (rgba 255 255 255 0.2) ] 
                            [ el [ Font.size 12, Font.semiBold ] (text model.conf.subTitle)
                            , el [ Font.size 11, alpha 0.5 ] (text ("Version " ++ model.conf.version))
                            ]
                        ]
                }
            ]

        , row [ spacing 20, alignRight, centerY ]
            [ el 
                [ pointer
                , Events.onClick MsgToggleThemeMenu
                , alpha (if model.themeMenuOpen then 1.0 else 0.6)
                , mouseOver [ alpha 1.0 ]
                , centerY
                , width (px 40)
                , height (px 36)
                , Font.color (rgb255 255 255 255)
                ] 
                Icons.palette
            
            , newTabLink [ alpha 0.6, mouseOver [ alpha 1.0 ], centerY ]
                { url = model.conf.githubUrl
                , label = 
                    row [ spacing 10, Font.color (rgb255 255 255 255) ] 
                        [ el [ centerY, Font.color (rgb255 255 255 255) ] Icons.github
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
            -- Verhindert, dass Klicks innerhalb des Menüs das "Click-Outside" Event der App triggern
            , htmlAttribute (Html.Events.stopPropagationOn "click" (Decode.succeed ( MsgNoOp, True )))
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
            , Font.color (rgb255 255 255 255)
            ]
            [ row [ width fill ]
                [ el [ Font.bold ] (text "Theme Controls")
                , el
                    [ alignRight
                    , pointer
                    , Events.onClick MsgCopyColor
                    , alpha 0.6
                    , mouseOver [ alpha 1.0 ]
                    , Font.color (rgb255 255 255 255)
                    ]
                    Icons.copy
                ]
            
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
                    , inFront <|
                        html <|
                            Html.input
                                [ Html.Attributes.type_ "color"
                                , Html.Attributes.value (hctToHex model.themeHue model.themeChroma model.themeTone)
                                , Html.Attributes.style "opacity" "0"
                                , Html.Attributes.style "width" "30px"
                                , Html.Attributes.style "height" "30px"
                                , Html.Attributes.style "cursor" "pointer"
                                , Html.Attributes.style "border" "none"
                                , Html.Events.onInput MsgSetHexColor
                                ]
                                []
                    ]
                    none
                ]

            , column [ width fill, spacing 15, paddingXY 0 10 ]
                [ hctSlider "Hue" model.themeHue 360 MsgSetHue
                , hctSlider "Chroma" model.themeChroma 150 MsgSetChroma
                , hctSlider "Tone" model.themeTone 100 MsgSetTone
                ]
            ]


viewIntrospection : Model -> State.Introspection -> Element Msg
viewIntrospection model introspection =
    column [ width fill ]
        (viewIntrospectionTitle model.conf introspection
            :: List.map (\( title, subs ) -> viewIntrospectionBody model title subs) introspection.variations
        )


viewIntrospectionTitle : Conf Msg -> State.Introspection -> Element Msg
viewIntrospectionTitle configuration introspection =
    column 
        [ Background.color configuration.greyF
        , padding configuration.mainPadding
        , spacing 10
        , width fill
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


viewSubSection : Model -> ( Element (), String ) -> Element Msg
viewSubSection model ( componentExample, componentExampleSourceCode ) =
    let
        ( disp, src ) =
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
            else if componentExample == text "special: LandingLayout.example" then
                ( Element.map (\_ -> MsgNoOp) (LandingLayout.view model.conf (text "Zentrierter Content Bereich")), "" )
            else if componentExample == text "special: MainLayout.example" then
                ( Element.map (\_ -> MsgNoOp) 
                    (MainLayout.view model.conf 
                        (text "Header Bereich")   -- Arg 2
                        (text "Sidebar Bereich")  -- Arg 3
                        (text "Hauptinhalt")      -- Arg 4
                    )
                , "" 
                )
            else 
                ( Element.map (\_ -> MsgNoOp) componentExample, componentExampleSourceCode )
    in
    row [ spacing 16, width fill ]
        [ el [ width <| fillPortion 2, height fill ] disp
        , el [ width <| fillPortion 3, height fill ] <| sourceCodeWrapper model.conf src
        ]


viewSomething : Model -> ( State.Introspection, ( String, List ( Element (), String ) ) ) -> Element Msg
viewSomething model ( introspection, ( title, listSubSection ) ) =
    let
        -- Hier erweitern: Wir wollen "About" UND "Layouts" im Vollbildmodus ohne Code-Box
        isFullWidthPage = 
            introspection.category == "About" || introspection.category == "Layouts"
    in
    column [ spacing 40, width fill ]
        [ viewIntrospectionTitle model.conf introspection
        
        , if isFullWidthPage then
            -- EINSPALTIG: Zeigt das Layout über die volle Breite
            column [ spacing 20, width fill, padding 40 ] 
                (List.map (\( bin, _ ) -> viewSubSectionFullWidth model bin) listSubSection)

          else
            -- ZWEISPALTIG: Standard für Atome, Moleküle etc. (Beispiel | Code)
            column [ spacing 0, width fill ] 
                [ viewSubSectionTitle title
                , column [ spacing 10, width fill, padding 40 ] 
                    (List.map (viewSubSection model) listSubSection)
                ]
        ]


viewSubSectionFullWidth : Model -> Element () -> Element Msg
viewSubSectionFullWidth model componentExample =
    el [ width fill ] (Element.map (\_ -> MsgNoOp) componentExample)


viewSubSectionTitle : String -> Element Msg
viewSubSectionTitle title =
    el 
        [ width fill, paddingXY 40 10, Background.color (rgb255 245 245 245), Font.size 16, Font.bold, Font.color (rgb255 100 100 100), Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }, Border.color (rgb255 230 230 230) ] 
        (text title)


viewIntrospectionForMenu : Conf Msg -> State.Introspection -> Bool -> Element Msg
viewIntrospectionForMenu configuration introspection open =
    let
        firstVariationName =
            introspection.variations 
                |> List.head 
                |> Maybe.map Tuple.first 
                |> Maybe.withDefault ""

        clickAction =
            link [ width fill ] 
                { label = menuLabel
                , url = routeToString <| RouteSubPage (Slug introspection.name) (Slug firstVariationName)
                }

        menuLabel =
            paragraph [ alignLeft, Font.bold, width fill ]
                [ el 
                    [ padding 5
                    , rotate (if open then pi / 2 else 0) 
                    , htmlAttribute (Html.Attributes.style "transition" "transform 0.2s ease-in-out")
                    ] 
                    (text "⟩ ")
                , el [ Font.size 18 ] <| text introspection.name
                ]

        hasMultipleVariations =
            List.length introspection.variations > 1
    in
    column [ Font.color (if open then Color.white else configuration.grey9), width fill ]
        [ clickAction
        
        , if open && hasMultipleVariations then
            column 
                [ height shrink
                , Font.size 16
                , Font.color configuration.greyD
                , spacing 8
                , paddingEach { bottom = 1, left = 26, right = 0, top = 12 }
                , clip 
                ] <|
                List.map (\( name, _ ) -> 
                    link [ mouseOver [ Font.color Color.primary ] ] 
                        { label = text name
                        , url = routeToString <| RouteSubPage (Slug introspection.name) (Slug name) 
                        }
                ) introspection.variations
          else
            none
        ]

sourceCodeWrapper : Conf Msg -> String -> Element Msg
sourceCodeWrapper configuration sourceCode =
    el [ Background.color configuration.grey3, Border.rounded 8, width fill, clip, scrollbars ] <|
        row [ Font.family [ Font.monospace ], Font.color configuration.grey9, Font.size 16, padding 16, width <| px 100 ] [ text sourceCode ]


hctToColor : Float -> Float -> Float -> Element.Color
hctToColor h c t =
    let
        hue = h / 360
        sat = clamp 0 1 (c / 100)
        light = clamp 0 1 (t / 100)
        f n =
            let
                k = Basics.toFloat (modBy 12 (round (n + hue * 12)))
                a = sat * min light (1 - light)
            in
            light - a * max -1 (min (min (k - 3) (9 - k)) 1)
    in
    Element.rgb (f 0) (f 8) (f 4)


hctSlider : String -> Float -> Float -> (Float -> Msg) -> Element Msg
hctSlider title value maxVal msg =
    column [ width fill, spacing 10 ]
        [ row [ width fill ]
            [ el [ Font.size 12, Font.color (rgb255 180 180 180) ] (text title)
            , el [ alignRight, Font.size 12, Font.color (rgb255 180 180 180) ] (text (String.fromInt (round value)))
            ]
        , Input.slider [ height (px 4), width fill, Background.color (rgba 1 1 1 0.1), Border.rounded 2 ]
            { onChange = msg, label = Input.labelHidden title, min = 0, max = maxVal, step = Just 1, value = value
            , thumb = Input.thumb [ width (px 16), height (px 16), Background.color (rgb255 255 255 255), Border.rounded 8, Border.shadow { offset = ( 0, 2 ), size = 1, blur = 4, color = rgba 0 0 0 0.2 } ]
            }
        ]


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
            let variation = List.filter (\( name, _ ) -> name == slug2) introspection.variations |> List.head
            in Maybe.map (\v -> ( introspection, v )) variation
        Nothing -> Nothing