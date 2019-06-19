import * as log from "loglevel";
if (process.env.NODE_ENV != "production") log.setLevel("debug");
import moment from "moment-timezone";

export class Utils {
  displayLocalDate(time, preciseTime) {
    // Ensure we return if it's a big future day
    if (preciseTime == null) {
      preciseTime = false;
    }
    if (time < window.tomorrow) {
      if (time > window.today) {
        return time.format("h:mma");
      } else if (time > window.yesterday) {
        return `Yesterday ${time.format("h:mma")}`;
      }
    }
    if (time.year() === moment().year()) {
      if (preciseTime) {
        return time.format("MMM Do[,] h:mma");
      } else {
        return time.format("MMM Do[,] ha");
      }
    } else {
      if (preciseTime) {
        return time.format("YYYY-MM-DD h:mma");
      } else {
        return time.format("YYYY-MM-DD");
      }
    }
  }

  localizeTimes() {
    if (!window.timezone) {
      window.timezone = moment.tz.guess();
    }
    moment.tz.setDefault(window.timezone);
    window.yesterday = moment()
      .subtract(1, "day")
      .startOf("day");
    window.today = moment().startOf("day");
    window.tomorrow = moment().endOf("day");

    let displayLocalDate = this.displayLocalDate;
    // Write local time
    $(".convertTime").each(function() {
      const $this = $(this);
      $this.removeClass("convertTime");
      $this.addClass("convertedTime"); // Because we style it sometimes
      const text = $this.text().trim();
      if (!(text.length > 0)) {
        return;
      }
      const time = moment(text, moment.ISO_8601);
      if (!time.isValid) {
        return;
      }
      return $this.text(displayLocalDate(time, $this.hasClass("preciseTime")));
    });

    // Write timezone
    return $(".convertTimezone").each(function() {
      const $this = $(this);
      $this.text(moment().format("z"));
      return $this.removeClass("convertTimezone");
    });
  }

  enableEscapeForModals() {
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
  }
}
