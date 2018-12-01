// Please make sure you edit this file at data-raw/templates/vegawidget.js
//  - then render data-raw/infrastructure.Rmd

HTMLWidgets.widget({

  name: "vegawidget",

  type: "output",

  factory: function(el, width, height) {

    var vega_promise = null;

    return {

      renderValue: function(x) {

        // initialise promise
        vega_promise = vegaEmbed(el, x.chart_spec, opt = x.embed_options);

        // fulfill promise by rendering the visualisation
        vega_promise
          .then(function(result) {
            // By removing the style (width and height) of the
            // enclosing element, we let the "chart" decide the space it
            // will occupy.
            // el.setAttribute("style", "");
            // console.log(el);
          })
          .catch(console.error);
      },

      // public function to get promise
      getPromise: function() {
        return vega_promise;
      },

      // generic function to call functions, a bit like R's do.call()
      callView: function(fn, params) {
        vega_promise.then(function(result) {
            var method = result.view[fn];
            method.apply(result.view, params);
            result.view.run();
          });
      },

      // Data functions

      // hard reset of data to the view
      changeView: function(params) {
        var changeset = vega.changeset()
                            .remove(function() {return true})
                            .insert(params.data);
        var args = [params.name, changeset];
        this.callView('change', args);
      },

      // TODO: the expected form of the data is different here than in the
      // changeView function
      loadData: function(name, data) {
        vega_promise.then(function(result) {
          result.view.insert(name, HTMLWidgets.dataframeToD3(data)).run();
        });
      },

      // Listener functions

      addEventListener: function(event_name, handler) {
        vega_promise.then(function(result) {
          result.view.addEventListener(event_name, handler);
        });
      },

      addSignalListener: function(signal_name, handler) {
        vega_promise.then(function(result) {
          result.view.addSignalListener(signal_name, handler);
        });
      }

    };

  }
});


// Helper functions to get view object via the htmlWidgets object

if (HTMLWidgets.shinyMode) {

  Shiny.addCustomMessageHandler('callView', function(message) {

    // it seems that `message` has `id`, `fn`, and `params`

    // get the correct HTMLWidget instance
    var htmlWidgetsObj = HTMLWidgets.find("#" + message.id);

    var validObj = typeof htmlWidgetsObj !== "undefined" & htmlWidgetsObj !== null;

    if (validObj) {
      // why a different API if the call is change?
      if (message.fn === "change") {
          htmlWidgetsObj.changeView(message.params);
       } else {
         htmlWidgetsObj.callView(message.fn, message.params);
       }
    }
  });
}

function getVegaPromise(selector) {

  // get the htmlWidgetsObj
  var htmlWidgetsObj = HTMLWidgets.find(selector);

  // verify the element (to be determined)

  // return the promise
  return(htmlWidgetsObj.getPromise());

}
