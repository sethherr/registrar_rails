// This is stuff that needs to happen on page load.
// Eventually, things will get more complicated and be split up - but for now, just one lame file

import * as log from "loglevel";
if (process.env.NODE_ENV != "production") log.setLevel("debug");

import { Utils } from "./utils.js";
import { AdminBase } from "./admin/base.js";

$(document).on("turbolinks:load", function() {
  window.utils = new Utils();
  utils.localizeTimes();
  utils.enableEscapeForModals();

  // Load the page specific things
  let body = document.getElementsByTagName("body")[0];
  let body_id = body.id;
  let is_admin = body.classList.contains("admin-body");
  let action_name = body.getAttribute("data-pageaction");

  if (is_admin) {
    window.adminBase = new AdminBase();
    adminBase.init();
  }
});
