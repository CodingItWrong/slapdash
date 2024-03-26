// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "prism/prism"
import * as bootstrap from "bootstrap"

Prism.manual = true

document.addEventListener("DOMContentLoaded", function(){
  Prism.highlightAll();
});
import "@hotwired/turbo-rails"
