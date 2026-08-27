/*
 * Kettle Lane Cats & Dogs — progressive enhancement, and nothing else.
 *
 * This file only ever talks to the DOM. It constructs no network client of any
 * kind, loads no further module at run time, and reads nothing it did not find
 * already in the page. Both pages that load it work completely with scripting
 * switched off: the filter buttons are the only feature here, and every card
 * they can hide is visible until this file chooses to hide one.
 *
 * Every function below stays well under the eight-branch proxy threshold the
 * Stage B complexity suite enforces.
 */

(function () {
  "use strict";

  var DEFAULT_PET = "both";

  // A card is shown when the reader asked for everything, when the card itself
  // applies to everything, or when the two simply agree.
  function cardMatches(card, pet) {
    var kind = card.getAttribute("data-pet");
    if (pet === DEFAULT_PET) {
      return true;
    }
    if (kind === DEFAULT_PET) {
      return true;
    }
    return kind === pet;
  }

  function applyFilter(group, pet) {
    var cards = document.querySelectorAll(".card");
    for (var i = 0; i < cards.length; i += 1) {
      cards[i].hidden = !cardMatches(cards[i], pet);
    }

    var buttons = group.querySelectorAll("button[data-filter]");
    for (var j = 0; j < buttons.length; j += 1) {
      var pressed = buttons[j].getAttribute("data-filter") === pet;
      buttons[j].setAttribute("aria-pressed", String(pressed));
    }
  }

  function handleFilterClick(group, event) {
    var target = event.target;
    var button = target.closest ? target.closest("button[data-filter]") : null;
    if (!button) {
      return;
    }
    applyFilter(group, button.getAttribute("data-filter"));
  }

  // One listener on the group rather than one per button: the markup owns the
  // set of choices, so adding a card or a button needs no change here.
  function initFilter() {
    var group = document.querySelector("[data-filter-group]");
    if (!group) {
      return;
    }
    group.addEventListener("click", function (event) {
      handleFilterClick(group, event);
    });
    applyFilter(group, DEFAULT_PET);
  }

  function markCurrentPage() {
    var last = document.location.pathname.split("/").pop();
    var page = last === "" ? "index.html" : last;
    var links = document.querySelectorAll("nav a[href]");
    for (var i = 0; i < links.length; i += 1) {
      if (links[i].getAttribute("href") === page) {
        links[i].setAttribute("aria-current", "page");
      }
    }
  }

  markCurrentPage();
  initFilter();
})();
