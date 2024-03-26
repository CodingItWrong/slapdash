// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import "prism/prism"
import * as bootstrap from "bootstrap"

Prism.manual = true

document.addEventListener("turbo:load", function(){
  Prism.highlightAll();
});

document.addEventListener("turbo:frame-render", function(){
  Prism.highlightAll();
});
