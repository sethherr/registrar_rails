import * as log from "loglevel";
if (process.env.NODE_ENV != "production") log.setLevel("debug");

export class AdminBase {
  init() {
    log.debug("admin party");
  }
}
