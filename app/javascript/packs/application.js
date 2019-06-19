/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Rails from "rails-ujs";
import Turbolinks from "turbolinks";
import "bootstrap/dist/js/bootstrap";

Rails.start();
Turbolinks.start();

import log from "./utils/log";
import LocalizeTimes from "./utils/localize_times";
import LoadFancySelects from "./utils/load_fancy_selects";
import EnableFilenameForUploads from "./utils/enable_filename_for_uploads";
import AdminBase from "./pages/admin_base.js";

$(document).on("turbolinks:load", function() {
  LocalizeTimes();
  LoadFancySelects();
  EnableFilenameForUploads();

  // Load the page specific things
  let body = document.getElementsByTagName("body")[0];
  let body_id = body.id;
  let is_admin = body.classList.contains("admin-body");
  let action_name = body.getAttribute("data-pageaction");

  if (is_admin) {
    const adminBase = AdminBase();
    adminBase.init();
  }
});

// Because it's nice to be able to access jQuery in the console, attach it ;)
window.$ = window.jQuery = jQuery;
