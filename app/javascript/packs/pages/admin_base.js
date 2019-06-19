import log from "../utils/log";

function AdminBase() {
  return {
    init() {
      log.debug("admin party");
    }
  };
}

export default AdminBase;
