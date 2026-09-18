(function ($) {
    "use strict";

    /*
        Hinweis zur ICE-Anpassung:
        Hier standen vorher vier Morris-Demo-Diagramme (Morris.Bar, Morris.Donut,
        Morris.Area, Morris.Line). Die Bibliothek morris.js wird vom Panel aber
        nicht eingebunden (siehe templates/footer.php) und die dazugehoerigen
        HTML-Elemente (#morris-bar-chart usw.) gibt es auf keiner Seite.

        Ergebnis: "Morris is not defined" - ein JavaScript-Fehler auf JEDER
        Seite, der den Rest dieser Datei abgebrochen hat.
        Die Demo-Diagramme sind daher entfernt.
    */
    var mainApp = {

        main_fun: function () {
            /*====================================
            METIS MENU
            ======================================*/
            $('#main-menu').metisMenu();

            /*====================================
              LOAD APPROPRIATE MENU BAR
           ======================================*/
            $(window).bind("load resize", function () {
                if ($(this).width() < 768) {
                    $('div.sidebar-collapse').addClass('collapse')
                } else {
                    $('div.sidebar-collapse').removeClass('collapse')
                }
            });
        },

        initialization: function () {
            mainApp.main_fun();
        }

    }
    // Initializing ///
	/* {LICENSE_INFOx} */

    $(document).ready(function () {
        mainApp.main_fun();
    });

}(jQuery));
