"use strict";

(function loadHighlightJs()
{
  var script = document.createElement("script");

  script.src = "../highlight/highlight.pack.js";
  script.type = "text/javascript";

  document.head.appendChild(script);

  console.log("Highlight script loaded.");

  hljs.initHighlightingOnLoad();
})();

