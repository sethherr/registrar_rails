const enableEscapeForModals = () => {
  $(".modal").on("show.bs.modal", () =>
    $(window).on("keyup", function(e) {
      if (e.keyCode === 27) {
        $(".modal").modal("hide"); // Escape key
      }
      return true;
    })
  );
  // Remove keyup trigger, clean up after yourself
  return $(".modal").on("hide.bs.modal", () => $(window).off("keyup"));
};

export default enableEscapeForModals;
