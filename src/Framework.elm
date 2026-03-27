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
import Html
import Html.Attributes
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


viewPage : Maybe WindowSize -> Model -> Element Msg
viewPage maybeWindowSize model =
    column
        [ height <|
            case maybeWindowSize of
                Just ws -> px ws.height
                Nothing -> fill
        , width fill
        , htmlAttribute (Html.Attributes.class "mw-ui-layout")
        ]
        [ -- HIER: Die interne Framework-Navbar
          viewFrameworkNavbar model

        , row
            [ height fill
            , width fill
            ]
            [ -- Sidebar
              el 
                [ height fill
                , width <| px 310
                , scrollbarY
                , clipX
                , htmlAttribute (Html.Attributes.class "mw-ui-sidebar") 
                ] <| 
                viewMenuColumn model
            
            , -- Content
              el 
                [ height fill
                , width fill
                , scrollbarY
                , htmlAttribute (Html.Attributes.class "mw-ui-content")
                ] <| 
                viewContentColumn model
            ]
        ]

-- Neue Funktion NUR für das Framework-Interface
viewFrameworkNavbar : Model -> Element Msg
viewFrameworkNavbar model =
    row
        [ width fill
        , paddingXY 30 15
        , Background.color (rgb255 51 51 51) -- Dein dunkles Anthrazit
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color (rgba 0 0 0 0.2)
        ]
        [ -- Platzhalter links
          none 
        , -- GitHub Link mit der neuen URL
          newTabLink [ alignRight, alpha 0.8, mouseOver [ alpha 1.0 ], centerY ]
            { url = "https://github.com/martenwindler/mw-ui-kit" -- Aktualisierter Link
            , label = 
                row [ spacing 10, Font.color (rgb255 255 255 255) ] 
                    [ el [ centerY ] githubIcon
                    , el [ Font.size 14, centerY ] (text "GitHub") 
                    ]
            }
        ]


githubIcon : Element msg
githubIcon =
    html <|
        Svg.svg
            [ Svg.Attributes.width "20"
            , Svg.Attributes.height "20"
            , Svg.Attributes.viewBox "0 0 24 24"
            , Svg.Attributes.style "fill: currentColor;" -- Nutzt die Textfarbe der Navbar
            ]
            [ Svg.path 
                [ Svg.Attributes.d "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" 
                ] 
                [] 
            ]

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
        [ -- Header Bereich
          viewLogo model.conf.titleLeftSide model.conf.subTitle model.conf.version
        
        -- Das dynamische Menü, gruppiert nach Atomic Design
        , column [ width fill ] <|
            List.map viewCategoryGroup orderedCategories
        ]


viewContentColumn : Model -> Element Msg
viewContentColumn model =
    case maybeSelected model of
        Just ( intro, variation ) ->
            column [ width fill, htmlAttribute (Html.Attributes.class "mw-ui-content-wrapper") ]
                [ viewSomething model ( intro, variation ) ]

        Nothing ->
            column [ width fill ]
                [ column [ padding <| model.conf.mainPadding + 100, spacing model.conf.mainPadding, width fill ]
                    [ el [ centerX ] <| viewLogo model.conf.title model.conf.subTitle model.conf.version
                    , el [ Font.size 24, centerX ] model.conf.introduction
                    , el [ centerX, alpha 0.2 ] <| Icon.chevronDown Color.grey 32
                    ]
                , column [ width fill ] <| List.map (\( intro, _ ) -> viewIntrospection model intro) model.introspections
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
        { label = column [ height shrink, spacing 10 ] [ el [ Font.size 60, Font.bold ] title, el [ Font.size 16, Font.bold ] <| text subTitle, el [ Font.size 14, Font.bold ] <| text <| "Version " ++ version ]
        , url = routeToString RouteHome
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
"""