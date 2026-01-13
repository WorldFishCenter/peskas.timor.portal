#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    apexchart_dep(),
    jquery_dep(),
    google_analytics(),
    shiny.i18n::usei18n(i18n),
    error_recovery_js(),
    client_cache_js(),
    tabler_page(
      title = "Peskas | East Timor",
      header(
        logo = peskas_logo(),
        version_flex(
          heading = i18n$t(pars$header$subtitle$text),
          subheading = "East Timor (v0.0.12-alpha)"
        ),
        user_ui()
      ),
      tab_menu(
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$home$text),
          ),
          id = "home", icon_home()
        ),
        # tab_menu_item(
        #  label = tagList(
        #    i18n$t(pars$header$nav$pds_tracks$text),
        #    # tags$span(
        #    #  class = 'badge bg-lime-lt',
        #    #  'New'
        #    # )
        #  ),
        #  id = "pds_tracks", icon_map()
        # ),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$catch$text)
          ),
          id = "catch", icon_scale()
        ),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$revenue$text)
          ),
          id = "revenue", icon_currency_dollar()
        ),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$market$text)
          ),
          id = "market", icon_market()
        ),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$composition$text)
          ),
          "catch-composition", icon_chart_pie()
        ),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$nutrients$text)
          ),
          id = "nutrients", icon_nutrients()
        ),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$about$text)
          ),
          id = "about", icon_info_circle()
        )
      ),
      tabset_panel(
        menu_id = "main_tabset",
        tab_panel(
          id = "home",
          tab_home_content(i18n)
        ),
        tab_panel(
          id = "revenue",
          tab_revenue_content(i18n)
        ),
        tab_panel(
          id = "market",
          tab_market_content(i18n)
        ),
        tab_panel(
          id = "catch",
          tab_catch_content(i18n)
        ),
        tab_panel(
          id = "catch-composition",
          tab_catch_composition(i18n)
        ),
        # tab_panel(
        #  id = "pds_tracks",
        #  tab_tracks_content(i18n)
        # ),
        tab_panel(
          id = "nutrients",
          tab_nutrients_content(i18n)
        ),
        tab_panel(
          id = "about",
          peskas_timor_about_ui(id = "about-text")
        )
      ),
      footer_panel(
        left_side_elements = tags$li(
          class = "list-inline-item",
          i18n$t(pars$footer$update_time$text),
          format(peskas.timor.portal::data_last_updated, "%c")
        ),
        right_side_elements = tagList(
          inline_li_link(
            content = "Licence",
            href = "https://github.com/WorldFishCenter/peskas.timor.portal/blob/main/LICENSE.md"
          ),
          inline_li_link(
            content = i18n$t(pars$footer$nav$code$text),
            href = "https://github.com/WorldFishCenter/peskas.timor.portal"
          )
        ),
        bottom = i18n$t("Copyright \u00a9 2021 Peskas. All rights reserved.")
      ),
      inactivity_modal(timeout_seconds = 5 * 60),
      settings_modal(),
      shinyjs::useShinyjs()
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @noRd
golem_add_external_resources <- function() {
  shiny::addResourcePath(
    "www", app_sys("app/www")
  )

  tags$head(
    # avoiding some overhead so that we don't need to use golem in production
    # favicon(),
    # bundle_resources(
    # path = app_sys('app/www'),
    # app_title = 'peskas.timor.portal'
    # )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}


apexchart_dep <- function() {
  htmltools::htmlDependency(
    name = "apexcharts",
    version = "3.26.2",
    src = c(href = "https://cdn.jsdelivr.net/npm/apexcharts@3.26.2/dist/"),
    script = "apexcharts.min.js",
    # Add cache control headers
    meta = list(
      "Cache-Control" = "public, max-age=31536000", # 1 year
      "Expires" = format(Sys.Date() + 365, "%a, %d %b %Y %H:%M:%S GMT")
    )
  )
}

jquery_dep <- function() {
  htmltools::htmlDependency(
    name = "jquery",
    version = "3.6.0",
    src = c(href = "https://code.jquery.com/"),
    script = "jquery-3.6.0.min.js",
    # Add cache control headers
    meta = list(
      "Cache-Control" = "public, max-age=31536000", # 1 year
      "Expires" = format(Sys.Date() + 365, "%a, %d %b %Y %H:%M:%S GMT")
    )
  )
}

#' Add client-side caching JavaScript utilities
client_cache_js <- function() {
  tags$script("
    // Client-side data caching utilities
    window.PeskasCache = {
      storage: window.sessionStorage || {},
      prefix: 'peskas_',

      set: function(key, data, ttl) {
        ttl = ttl || 300000; // 5 minutes default
        var item = {
          data: data,
          timestamp: Date.now(),
          ttl: ttl
        };
        try {
          this.storage.setItem(this.prefix + key, JSON.stringify(item));
        } catch(e) {
          console.warn('Cache storage failed:', e);
        }
      },

      get: function(key) {
        try {
          var item = this.storage.getItem(this.prefix + key);
          if (!item) return null;

          item = JSON.parse(item);
          if (Date.now() - item.timestamp > item.ttl) {
            this.remove(key);
            return null;
          }

          return item.data;
        } catch(e) {
          console.warn('Cache retrieval failed:', e);
          return null;
        }
      },

      remove: function(key) {
        try {
          this.storage.removeItem(this.prefix + key);
        } catch(e) {
          console.warn('Cache removal failed:', e);
        }
      },

      clear: function() {
        try {
          var keys = Object.keys(this.storage);
          for (var i = 0; i < keys.length; i++) {
            if (keys[i].startsWith(this.prefix)) {
              this.storage.removeItem(keys[i]);
            }
          }
        } catch(e) {
          console.warn('Cache clear failed:', e);
        }
      }
    };

    // Preload critical resources
    window.addEventListener('load', function() {
      // Preload common chart configurations
      var commonChartConfig = {
        chart: { animations: { enabled: false } },
        toolbar: { show: false },
        dataLabels: { enabled: false }
      };

      PeskasCache.set('chart_config_base', commonChartConfig, 3600000); // 1 hour

      // Prefetch critical API endpoints (if any)
      console.log('Peskas client cache initialized');
    });

    // Service Worker registration for advanced caching
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', function() {
        navigator.serviceWorker.register('/sw.js').then(function(registration) {
          console.log('SW registered: ', registration);
        }).catch(function(registrationError) {
          console.log('SW registration failed: ', registrationError);
        });
      });
    }
  ")
}
