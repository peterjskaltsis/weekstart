module Page exposing (Page(..), view, viewErrors)

import Api exposing (Cred)
import Avatar
import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, i, img, li, nav, p, span, text, ul)
import Html.Attributes exposing (class, classList, href, style)
import Html.Events exposing (onClick)
import Route exposing (Route)
import Session exposing (Session)
import Username exposing (Username)
import Viewer exposing (Viewer)


{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.
-}
type Page
    = Other
    | Home
    | Month


{-| Take a page's Html and frames it with a header and footer.
The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.
isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)
-}
view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = "Weekstart • " ++ title
    , body =
        --viewHeader page maybeViewer ::
        content :: [ viewFooter page ]
    }


viewHeader : Page -> Maybe Viewer -> Html msg
viewHeader page maybeViewer =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "WeekStart" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                navbarLink page Route.Home [ text "Home" ]
                    :: viewMenu page maybeViewer
            ]
        ]


viewMenu : Page -> Maybe Viewer -> List (Html msg)
viewMenu page maybeViewer =
    let
        linkTo =
            navbarLink page
    in
    case maybeViewer of
        Just viewer ->
            let
                username =
                    Viewer.username viewer

                avatar =
                    Viewer.avatar viewer
            in
            [ linkTo Route.Home [ i [ class "ion-compose" ] [], text "\u{00A0}Home" ]
            ]

        Nothing ->
            [ linkTo Route.Login [ text "Sign in" ]
            , linkTo Route.Root [ text "Sign up" ]
            ]


viewFooter : Page -> Html msg
viewFooter page =
    footer []
        [ div [ class "wrapper" ]
            [ div [ class "footer" ]
                [ a [ class "logo-font", Route.href Route.Home, style "marginRight" ".25rem" ] [ text "WeekStart " ]
                , span [ class "attribution" ]
                    [ text " • Made by "
                    , a [ href "https://peter-s.now.sh" ] [ text "Peter S." ]
                    ]
                , div [ class "footer-links" ]
                    [ if page /= Home then
                        a [ class "btn btn-primary", Route.href Route.Home ] [ text "My Weekly Brief ", i [ class "fas fa-calendar-alt", style "marginLeft" ".25rem" ] [] ]

                      else
                        a [ class "btn btn-primary", Route.href Route.Month ] [ text "My Monthly Brief ", i [ class "fas fa-calendar-alt", style "marginLeft" ".25rem" ] [] ]
                    ]
                ]
            ]
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        _ ->
            False


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""

    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
