// Polyfills and compatibility ------------------------------------------------
var decoder = decodeURIComponent || unescape;
if (!Array.prototype.includes) {
  Array.prototype.includes = function (thing) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] == thing) return true;
    }
    return false;
  };
}
if (!String.prototype.trim) {
  String.prototype.trim = function () {
    return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
  };
}

// Status panel implementation ------------------------------------------------
//status_tab_parts expects a list to be returned, to which we'll send a list within a list
//with just "loading" to not appear broken.
var status_tab_parts = [["Loading..."]];
var current_tab = null;
//mc_tab_parts expects a list to be returned, to which we'll send a list within a list
//with just "loading" to not appear broken.
var mc_tab_parts = [["Loading..."]];
var href_token = null;
var verb_tabs = [];
var verbs = [["", ""]]; // list with a list inside
var tickets = [];
var interviewManager = { status: "", interviews: [] };
var sdql2 = [];
var permanent_tabs = []; // tabs that won't be cleared by wipes
var turfcontents = [];
var turfname = "";
var imageRetryDelay = 500;
var imageRetryLimit = 50;
var menu = document.getElementById("menu");
var statcontentdiv = document.getElementById("statcontent");
var storedimages = [];
var split_admin_tabs = false;
var tab_prefs = {
  order: [],
  hidden: [],
  colors: {},
  structured: null,
  max_buttons_per_row: {},
};
var tab_search = {};
var favorites = [];
var favorites_request_pending = false;
var contextVerb = null;
var contextMenu = document.createElement("div");
contextMenu.className = "context-menu";
var contextItem = document.createElement("div");
contextItem.className = "context-menu-item";
contextMenu.appendChild(contextItem);
document.body.appendChild(contextMenu);

function hide_context_menu() {
  contextMenu.style.display = "none";
}

function show_context_menu(x, y, command) {
  contextVerb = command;
  contextItem.textContent = favorites.includes(command)
    ? "Remove from Favorites"
    : "Add to Favorites";
  contextItem.onclick = function () {
    if (favorites.includes(contextVerb)) {
      remove_favorite(contextVerb);
    } else {
      add_favorite(contextVerb);
    }
    hide_context_menu();
  };
  contextMenu.style.left = x + "px";
  contextMenu.style.top = y + "px";
  contextMenu.style.display = "block";
}

document.addEventListener("click", hide_context_menu);

function normalize_tab_name(name) {
  if (!name) {
    return "";
  }
  if (name.indexOf(".") != -1) {
    var splitName = name.split(".");
    if (split_admin_tabs && splitName[0] === "Admin") {
      return splitName[1];
    }
    return splitName[0];
  }
  return name;
}

function normalize_tab_list(tabList) {
  var normalized = [];
  if (!Array.isArray(tabList)) {
    return normalized;
  }
  for (var i = 0; i < tabList.length; i++) {
    var tabName = normalize_tab_name(tabList[i]);
    if (tabName && !normalized.includes(tabName)) {
      normalized.push(tabName);
    }
  }
  return normalized;
}

function is_core_tab(name) {
  return name === "Status" || name === "Favorites" || name === "Settings";
}

function is_tab_hidden(name) {
  if (!name || is_core_tab(name)) {
    return false;
  }
  return Array.isArray(tab_prefs.hidden) && tab_prefs.hidden.includes(name);
}

function get_tab_order(name) {
  if (Array.isArray(tab_prefs.order)) {
    var index = tab_prefs.order.indexOf(name);
    if (index != -1) {
      return index + 1;
    }
  }
  var defaults = {
    Status: 10,
    Favorites: 20,
    Admin: 30,
    Server: 40,
    Debug: 50,
    Mapping: 60,
    Mentor: 70,
    OOC: 80,
    IC: 90,
    MC: 100,
    Tickets: 110,
    SDQL2: 120,
    Settings: 1000,
  };
  if (defaults.hasOwnProperty(name)) {
    return defaults[name];
  }
  return 500 + name.toUpperCase().charCodeAt(0);
}

function apply_tab_color(button, name) {
  if (!button) {
    return;
  }
  var color = tab_prefs.colors && tab_prefs.colors[name];
  if (typeof color == "string" && color.trim().length) {
    button.style.setProperty("--tab-active-bg", color.trim());
  } else {
    button.style.removeProperty("--tab-active-bg");
  }
}

function is_tab_grouped(name) {
  if (!Array.isArray(tab_prefs.structured)) {
    return true;
  }
  return tab_prefs.structured.includes(name);
}

function get_tab_button_limit(name) {
  var raw =
    tab_prefs.max_buttons_per_row && tab_prefs.max_buttons_per_row[name];
  var limit = parseInt(raw, 10);
  if (isNaN(limit) || limit < 1 || limit > 20) {
    return null;
  }
  return limit;
}

function apply_grid_item_layout(item, tabName) {
  var limit = get_tab_button_limit(tabName);
  if (!limit) {
    item.style.removeProperty("width");
    item.style.removeProperty("flex-basis");
    return;
  }
  var width = 100 / limit + "%";
  item.style.width = width;
  item.style.flexBasis = width;
}

function send_tab_prefs_to_byond() {
  Byond.sendMessage("Update-Tab-Preferences", {
    order: Array.isArray(tab_prefs.order) ? tab_prefs.order.slice() : [],
    hidden: Array.isArray(tab_prefs.hidden) ? tab_prefs.hidden.slice() : [],
    colors: tab_prefs.colors || {},
    structured: Array.isArray(tab_prefs.structured)
      ? tab_prefs.structured.slice()
      : [],
    max_buttons_per_row: tab_prefs.max_buttons_per_row || {},
  });
}

function apply_menu_order_and_colors() {
  for (var i = 0; i < menu.children.length; i++) {
    var id = menu.children[i].id;
    menu.children[i].style.order = get_tab_order(id);
    apply_tab_color(menu.children[i], id);
  }
}

function make_context_menu(command) {
  return function (e) {
    e.preventDefault();
    show_context_menu(e.pageX, e.pageY, command);
  };
}

function add_favorite(command) {
  if (!command) {
    return;
  }
  if (!favorites.includes(command)) {
    favorites.push(command);
  }
  Byond.sendMessage("Add-Favorite", { command: command });
  if (current_tab == "Favorites") {
    draw_favorites();
  } else if (verb_tabs.includes(current_tab)) {
    draw_verbs(current_tab);
  }
}

function remove_favorite(command) {
  if (!command) {
    return;
  }
  var index = favorites.indexOf(command);
  if (index > -1) {
    favorites.splice(index, 1);
  }
  Byond.sendMessage("Remove-Favorite", { command: command });
  if (current_tab == "Favorites") {
    draw_favorites();
  } else if (verb_tabs.includes(current_tab)) {
    draw_verbs(current_tab);
  }
}

function normalize_favorites(payload) {
  var normalized = [];
  if (Array.isArray(payload)) {
    for (var i = 0; i < payload.length; i++) {
      if (typeof payload[i] == "string" && payload[i].length) {
        normalized.push(payload[i]);
      }
    }
  } else if (payload && typeof payload == "object") {
    for (var key in payload) {
      if (
        Object.prototype.hasOwnProperty.call(payload, key) &&
        typeof payload[key] == "string" &&
        payload[key].length
      ) {
        normalized.push(payload[key]);
      }
    }
  }
  return normalized;
}

function update_favorites(payload) {
  favorites_request_pending = false;
  favorites = normalize_favorites(payload);
  if (current_tab == "Favorites") {
    draw_favorites();
  } else if (verb_tabs.includes(current_tab)) {
    draw_verbs(current_tab);
  }
}

function request_favorites() {
  if (favorites_request_pending) {
    return;
  }
  favorites_request_pending = true;
  Byond.sendMessage("Update-Favorites");
}

function draw_favorites() {
  statcontentdiv.textContent = "";
  draw_content_header("Favorites", "Favorites");
  if (!favorites.length) {
    var empty = document.createElement("div");
    empty.className = "favorites-empty";
    empty.textContent = favorites_request_pending
      ? "Loading favorites..."
      : "No favorites yet. Right-click a verb to add it here, then drag to reorder.";
    statcontentdiv.appendChild(empty);
    return;
  }
  var filterText = tab_search["Favorites"] || "";
  var table = document.createElement("div");
  table.className = "grid-container favorites-grid";
  var shownFavorites = 0;
  for (var i = 0; i < favorites.length; i++) {
    var command = favorites[i];
    if (
      filterText &&
      command.toLowerCase().indexOf(filterText.toLowerCase()) == -1
    ) {
      continue;
    }
    var a = document.createElement("a");
    a.href = "#";
    a.onclick = make_verb_onclick(command.replace(/\s/g, "-"));
    a.oncontextmenu = make_context_menu(command);
    a.className = "grid-item";
    apply_grid_item_layout(a, "Favorites");
    a.draggable = true;
    a.setAttribute("data-fav", command);
    a.ondragstart = make_fav_dragstart(command);
    a.ondragover = make_fav_dragover(command);
    a.ondragleave = fav_dragleave;
    a.ondrop = make_fav_drop(command);
    a.ondragend = fav_dragend;
    var t = document.createElement("span");
    t.textContent = command;
    t.className = "grid-item-text";
    a.appendChild(t);
    var favoriteToggle = document.createElement("span");
    favoriteToggle.className = "grid-favorite-toggle is-favorite";
    favoriteToggle.title = "Remove from Favorites";
    favoriteToggle.onclick = make_favorite_toggle(command);
    a.appendChild(favoriteToggle);
    table.appendChild(a);
    shownFavorites++;
  }
  if (!shownFavorites) {
    var emptyFilter = document.createElement("div");
    emptyFilter.className = "favorites-empty";
    emptyFilter.textContent = "No favorites match the current filter.";
    statcontentdiv.appendChild(emptyFilter);
    return;
  }
  document.getElementById("statcontent").appendChild(table);
}

var fav_dragged = null;

function clear_fav_drag_markers() {
  var items = document.querySelectorAll(".favorites-grid .grid-item");
  for (var i = 0; i < items.length; i++) {
    items[i].classList.remove("dragging");
    items[i].classList.remove("drop-target");
  }
}

function mark_dragged_favorite(command) {
  var items = document.querySelectorAll(".favorites-grid .grid-item");
  for (var i = 0; i < items.length; i++) {
    if (items[i].getAttribute("data-fav") === command) {
      items[i].classList.add("dragging");
      return;
    }
  }
}

function make_fav_dragstart(command) {
  return function (e) {
    fav_dragged = command;
    clear_fav_drag_markers();
    this.classList.add("dragging");
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", command);
  };
}

function make_fav_dragover(command) {
  return function (e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
    if (fav_dragged && command !== fav_dragged) {
      clear_fav_drag_markers();
      this.classList.add("drop-target");
      mark_dragged_favorite(fav_dragged);
    }
  };
}

function fav_dragleave() {
  this.classList.remove("drop-target");
}

function make_fav_drop(targetCommand) {
  return function (e) {
    e.preventDefault();
    clear_fav_drag_markers();
    if (!fav_dragged || fav_dragged === targetCommand) {
      fav_dragged = null;
      return;
    }
    var draggedIndex = favorites.indexOf(fav_dragged);
    var targetIndex = favorites.indexOf(targetCommand);
    if (draggedIndex === -1 || targetIndex === -1) {
      fav_dragged = null;
      return;
    }
    favorites.splice(draggedIndex, 1);
    favorites.splice(targetIndex, 0, fav_dragged);
    Byond.sendMessage("Reorder-Favorites", { order: favorites.slice() });
    fav_dragged = null;
    draw_favorites();
  };
}

function fav_dragend() {
  fav_dragged = null;
  clear_fav_drag_markers();
}

// Any BYOND commands that could result in the client's focus changing go through this
// to ensure that when we relinquish our focus, we don't do it after the result of
// a command has already taken focus for itself.
function run_after_focus(callback) {
  setTimeout(callback, 0);
}

function createStatusTab(name) {
  name = normalize_tab_name(name);
  if (document.getElementById(name) || name.trim() == "") {
    return;
  }
  if (is_tab_hidden(name)) {
    SendTabToByond(name);
    return;
  }
  if (!verb_tabs.includes(name) && !permanent_tabs.includes(name)) {
    return;
  }
  var button = document.createElement("DIV");
  button.onclick = function () {
    tab_change(name);
    this.blur();
    statcontentdiv.focus();
  };
  button.id = name;
  button.textContent = name;
  button.className = "button";
  button.style.order = get_tab_order(name);
  apply_tab_color(button, name);
  menu.appendChild(button);
  SendTabToByond(name);
}

function hideStatusTab(name) {
  var tab = document.getElementById(name);
  if (!tab) {
    return;
  }
  menu.removeChild(tab);
}

function removeStatusTab(name) {
  if (!document.getElementById(name) || permanent_tabs.includes(name)) {
    return;
  }
  for (var i = verb_tabs.length - 1; i >= 0; --i) {
    if (verb_tabs[i] == name) {
      verb_tabs.splice(i, 1);
    }
  }
  menu.removeChild(document.getElementById(name));
  TakeTabFromByond(name);
}

function sortVerbs() {
  verbs.sort(function (a, b) {
    var selector = a[0] == b[0] ? 1 : 0;
    if (a[selector].toUpperCase() < b[selector].toUpperCase()) {
      return 1;
    } else if (a[selector].toUpperCase() > b[selector].toUpperCase()) {
      return -1;
    }
    return 0;
  });
}

function addPermanentTab(name) {
  if (!permanent_tabs.includes(name)) {
    permanent_tabs.push(name);
  }
  createStatusTab(name);
}

function removePermanentTab(name) {
  for (var i = permanent_tabs.length - 1; i >= 0; --i) {
    if (permanent_tabs[i] == name) {
      permanent_tabs.splice(i, 1);
    }
  }
  removeStatusTab(name);
}

function checkStatusTab() {
  for (var i = menu.children.length - 1; i >= 0; i--) {
    if (
      is_tab_hidden(menu.children[i].id) ||
      (!verb_tabs.includes(menu.children[i].id) &&
        !permanent_tabs.includes(menu.children[i].id))
    ) {
      menu.removeChild(menu.children[i]);
    }
  }
}

function remove_verb(v) {
  var verb_to_remove = v; // to_remove = [verb:category, verb:name]
  for (var i = verbs.length - 1; i >= 0; i--) {
    var part_to_remove = verbs[i];
    if (part_to_remove[1] == verb_to_remove[1]) {
      verbs.splice(i, 1);
    }
  }
}

function check_verbs() {
  for (var v = verb_tabs.length - 1; v >= 0; v--) {
    verbs_cat_check(verb_tabs[v]);
  }
}

function verbs_cat_check(cat) {
  var tabCat = normalize_tab_name(cat);
  var verbs_in_cat = 0;
  var verbcat = "";
  if (!verb_tabs.includes(tabCat)) {
    removeStatusTab(tabCat);
    return;
  }
  for (var v = 0; v < verbs.length; v++) {
    var part = verbs[v];
    verbcat = normalize_tab_name(part[0]);
    if (verbcat != tabCat || verbcat.trim() == "") {
      continue;
    } else {
      verbs_in_cat = 1;
      break; // we only need one
    }
  }
  if (verbs_in_cat != 1) {
    removeStatusTab(tabCat);
    if (current_tab == tabCat) tab_change("Status");
  }
}

function findVerbindex(name, verblist) {
  for (var i = 0; i < verblist.length; i++) {
    var part = verblist[i];
    if (part[1] == name) return i;
  }
}
function wipe_verbs() {
  verbs = [["", ""]];
  verb_tabs = [];
  checkStatusTab(); // remove all empty verb tabs
}

function update_verbs() {
  wipe_verbs();
  Byond.sendMessage("Update-Verbs");
}

function SendTabsToByond() {
  var tabstosend = [];
  tabstosend = tabstosend.concat(permanent_tabs, verb_tabs);
  for (var i = 0; i < tabstosend.length; i++) {
    SendTabToByond(tabstosend[i]);
  }
}

function SendTabToByond(tab) {
  Byond.sendMessage("Send-Tabs", { tab: tab });
}

//Byond can't have this tab anymore since we're removing it
function TakeTabFromByond(tab) {
  Byond.sendMessage("Remove-Tabs", { tab: tab });
}

function tab_change(tab) {
  if (tab == current_tab) return;
  if (document.getElementById(current_tab))
    document.getElementById(current_tab).className = "button"; // disable active on last button
  current_tab = tab;
  set_byond_tab(tab);
  if (document.getElementById(tab))
    document.getElementById(tab).className = "button active"; // make current button active
  var verb_tabs_thingy = verb_tabs.includes(tab);
  statcontentdiv.className = "statcontent";
  if (tab == "Status") {
    draw_status();
  } else if (tab == "Favorites") {
    request_favorites();
    draw_favorites();
  } else if (tab == "MC") {
    draw_mc();
  } else if (verb_tabs_thingy) {
    draw_verbs(tab);
  } else if (tab == "Debug Stat Panel") {
    draw_debug();
  } else if (tab == "Tickets") {
    draw_tickets();
    draw_interviews();
  } else if (tab == "Settings") {
    draw_statpanel_settings();
  } else if (tab == "SDQL2") {
    draw_sdql2();
  } else if (tab == turfname) {
    draw_listedturf();
  } else {
    statcontentdiv.textContent = "Loading...";
  }
  Byond.winset(Byond.windowId, {
    "is-visible": true,
  });
}

function set_byond_tab(tab) {
  Byond.sendMessage("Set-Tab", { tab: tab });
}

function draw_debug() {
  statcontentdiv.textContent = "";
  var wipeverbstabs = document.createElement("div");
  var link = document.createElement("a");
  link.onclick = function () {
    wipe_verbs();
  };
  link.textContent = "Wipe All Verbs";
  wipeverbstabs.appendChild(link);
  document.getElementById("statcontent").appendChild(wipeverbstabs);
  var wipeUpdateVerbsTabs = document.createElement("div");
  var updateLink = document.createElement("a");
  updateLink.onclick = function () {
    update_verbs();
  };
  updateLink.textContent = "Wipe and Update All Verbs";
  wipeUpdateVerbsTabs.appendChild(updateLink);
  document.getElementById("statcontent").appendChild(wipeUpdateVerbsTabs);
  var text = document.createElement("div");
  text.textContent = "Verb Tabs:";
  document.getElementById("statcontent").appendChild(text);
  var table1 = document.createElement("table");
  for (var i = 0; i < verb_tabs.length; i++) {
    var part = verb_tabs[i];
    // Hide subgroups except admin subgroups if they are split
    if (verb_tabs[i].lastIndexOf(".") != -1) {
      var splitName = verb_tabs[i].split(".");
      if (split_admin_tabs && splitName[0] === "Admin") part = splitName[1];
      else continue;
    }
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part;
    var a = document.createElement("a");
    a.onclick = (function (part) {
      return function () {
        removeStatusTab(part);
      };
    })(part);
    a.textContent = " Delete Tab " + part;
    td1.appendChild(a);
    tr.appendChild(td1);
    table1.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table1);
  var header2 = document.createElement("div");
  header2.textContent = "Verbs:";
  document.getElementById("statcontent").appendChild(header2);
  var table2 = document.createElement("table");
  for (var v = 0; v < verbs.length; v++) {
    var part2 = verbs[v];
    var trr = document.createElement("tr");
    var tdd1 = document.createElement("td");
    tdd1.textContent = part2[0];
    var tdd2 = document.createElement("td");
    tdd2.textContent = part2[1];
    trr.appendChild(tdd1);
    trr.appendChild(tdd2);
    table2.appendChild(trr);
  }
  document.getElementById("statcontent").appendChild(table2);
  var text3 = document.createElement("div");
  text3.textContent = "Permanent Tabs:";
  document.getElementById("statcontent").appendChild(text3);
  var table3 = document.createElement("table");
  for (var i = 0; i < permanent_tabs.length; i++) {
    var part3 = permanent_tabs[i];
    var trrr = document.createElement("tr");
    var tddd1 = document.createElement("td");
    tddd1.textContent = part3;
    trrr.appendChild(tddd1);
    table3.appendChild(trrr);
  }
  document.getElementById("statcontent").appendChild(table3);
}
function draw_status() {
  if (!document.getElementById("Status")) {
    createStatusTab("Status");
    current_tab = "Status";
  }
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  for (var i = 0; i < status_tab_parts.length; i++) {
    var part = status_tab_parts[i];
    if (!Array.isArray(part)) {
      var div = document.createElement("div");
      if (part.trim() == "") {
        table.appendChild(document.createElement("br"));
      } else {
        div.textContent = part;
        table.appendChild(div);
      }
    } else {
      var div;
      if (part[0].trim() == "same_line") {
        var a = document.createElement("a");
        a.href = "byond://?" + part[2];
        a.textContent = part[1];
        div.appendChild(a);
      } else {
        div = document.createElement("div");
        if (part[0].trim() == "") {
          table.appendChild(document.createElement("br"));
        } else {
          div.textContent = part[0];
          if (part[2]) {
            var a = document.createElement("a");
            a.href = "byond://?" + part[2];
            a.textContent = part[1];
            div.appendChild(a);
          }
          table.appendChild(div);
        }
      }
    }
  }
  document.getElementById("statcontent").appendChild(table);
  if (verb_tabs.length == 0 || !verbs) {
    Byond.command("Fix-Stat-Panel");
  }
}

function draw_mc() {
  statcontentdiv.textContent = "";
  statcontentdiv.className = "mcstatcontent";
  var table = document.createElement("table");
  for (var i = 0; i < mc_tab_parts.length; i++) {
    var part = mc_tab_parts[i];
    var tr = document.createElement("tr");
    var td0 = document.createElement("td");
    td0.className = "monospace";
    td0.textContent = part[0];
    var td1 = document.createElement("td");
    td1.textContent = part[1];
    var td2 = document.createElement("td");
    if (part[3]) {
      var a = document.createElement("a");
      a.href =
        "byond://?_src_=vars;admin_token=" + href_token + ";Vars=" + part[3];
      a.textContent = part[2];
      td2.appendChild(a);
    } else {
      td2.textContent = part[2];
    }
    tr.appendChild(td0);
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function remove_tickets() {
  if (tickets) {
    tickets = [];
    removePermanentTab("Tickets");
    if (current_tab == "Tickets") tab_change("Status");
  }
  checkStatusTab();
}

function remove_sdql2() {
  if (sdql2) {
    sdql2 = [];
    removePermanentTab("SDQL2");
    if (current_tab == "SDQL2") tab_change("Status");
  }
  checkStatusTab();
}

function remove_interviews() {
  if (tickets) {
    tickets = [];
  }
  checkStatusTab();
}

function iconError(e) {
  if (current_tab != turfname) {
    return;
  }
  setTimeout(function () {
    var node = e.target;
    var current_attempts = Number(node.getAttribute("data-attempts")) || 0;
    if (current_attempts > imageRetryLimit) {
      return;
    }
    var src = node.src;
    node.src = null;
    node.src = src + "#" + current_attempts;
    node.setAttribute("data-attempts", current_attempts + 1);
    draw_listedturf();
  }, imageRetryDelay);
}

function draw_listedturf() {
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  for (var i = 0; i < turfcontents.length; i++) {
    var part = turfcontents[i];
    var clickfunc = (function (part) {
      // The outer function is used to close over a fresh "part" variable,
      // rather than every onmousedown getting the "part" of the last entry.
      return function (e) {
        e.preventDefault();
        clickcatcher = "byond://?src=" + part[1];
        switch (e.button) {
          case 1:
            clickcatcher += ";statpanel_item_click=middle";
            break;
          case 2:
            clickcatcher += ";statpanel_item_click=right";
            break;
          default:
            clickcatcher += ";statpanel_item_click=left";
        }
        if (e.shiftKey) {
          clickcatcher += ";statpanel_item_shiftclick=1";
        }
        if (e.ctrlKey) {
          clickcatcher += ";statpanel_item_ctrlclick=1";
        }
        if (e.altKey) {
          clickcatcher += ";statpanel_item_altclick=1";
        }
        window.location.href = clickcatcher;
      };
    })(part);
    if (storedimages[part[1]] == null && part[2]) {
      var img = document.createElement("img");
      img.src = part[2];
      img.id = part[1];
      storedimages[part[1]] = part[2];
      img.onerror = iconError;
      img.onmousedown = clickfunc;
      table.appendChild(img);
    } else {
      var img = document.createElement("img");
      img.onerror = iconError;
      img.onmousedown = clickfunc;
      img.src = storedimages[part[1]];
      img.id = part[1];
      table.appendChild(img);
    }
    var b = document.createElement("div");
    var clickcatcher = "";
    b.className = "link";
    b.onmousedown = clickfunc;
    b.textContent = part[0];
    table.appendChild(b);
    table.appendChild(document.createElement("br"));
  }
  document.getElementById("statcontent").appendChild(table);
}

function remove_listedturf() {
  removePermanentTab(turfname);
  checkStatusTab();
  if (current_tab == turfname) {
    tab_change("Status");
  }
}

function remove_mc() {
  removePermanentTab("MC");
  if (current_tab == "MC") {
    tab_change("Status");
  }
}

function draw_sdql2() {
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  for (var i = 0; i < sdql2.length; i++) {
    var part = sdql2[i];
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part[0];
    var td2 = document.createElement("td");
    if (part[2]) {
      var a = document.createElement("a");
      a.href = "byond://?src=" + part[2] + ";statpanel_item_click=left";
      a.textContent = part[1];
      td2.appendChild(a);
    } else {
      td2.textContent = part[1];
    }
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function draw_tickets() {
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  if (!tickets) {
    return;
  }
  for (var i = 0; i < tickets.length; i++) {
    var part = tickets[i];
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part[0];
    var td2 = document.createElement("td");
    if (part[2]) {
      var a = document.createElement("a");
      a.href =
        "byond://?_src_=holder;admin_token=" +
        href_token +
        ";ahelp=" +
        part[2] +
        ";ahelp_action=ticket;statpanel_item_click=left;action=ticket";
      a.textContent = part[1];
      td2.appendChild(a);
    } else if (part[3]) {
      var a = document.createElement("a");
      a.href = "byond://?src=" + part[3] + ";statpanel_item_click=left";
      a.textContent = part[1];
      td2.appendChild(a);
    } else {
      td2.textContent = part[1];
    }
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function draw_interviews() {
  var body = document.createElement("div");
  var header = document.createElement("h3");
  header.textContent = "Interviews";
  body.appendChild(header);
  var manDiv = document.createElement("div");
  manDiv.className = "interview_panel_controls";
  var manLink = document.createElement("a");
  manLink.textContent = "Open Interview Manager Panel";
  manLink.href =
    "byond://?_src_=holder;admin_token=" +
    href_token +
    ";interview_man=1;statpanel_item_click=left";
  manDiv.appendChild(manLink);
  body.appendChild(manDiv);

  // List interview stats
  var statsDiv = document.createElement("table");
  statsDiv.className = "interview_panel_stats";
  for (var key in interviewManager.status) {
    var d = document.createElement("div");
    var tr = document.createElement("tr");
    var stat_name = document.createElement("td");
    var stat_text = document.createElement("td");
    stat_name.textContent = key;
    stat_text.textContent = interviewManager.status[key];
    tr.appendChild(stat_name);
    tr.appendChild(stat_text);
    statsDiv.appendChild(tr);
  }
  body.appendChild(statsDiv);
  document.getElementById("statcontent").appendChild(body);

  // List interviews if any are open
  var table = document.createElement("table");
  table.className = "interview_panel_table";
  if (!interviewManager) {
    return;
  }
  for (var i = 0; i < interviewManager.interviews.length; i++) {
    var part = interviewManager.interviews[i];
    var tr = document.createElement("tr");
    var td = document.createElement("td");
    var a = document.createElement("a");
    a.textContent = part["status"];
    a.href =
      "byond://?_src_=holder;admin_token=" +
      href_token +
      ";interview=" +
      part["ref"] +
      ";statpanel_item_click=left";
    td.appendChild(a);
    tr.appendChild(td);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function make_verb_onclick(command) {
  return function () {
    run_after_focus(function () {
      Byond.command(command);
    });
  };
}

function make_favorite_toggle(command) {
  return function (e) {
    e.preventDefault();
    e.stopPropagation();
    if (favorites.includes(command)) {
      remove_favorite(command);
    } else {
      add_favorite(command);
    }
  };
}

function draw_content_header(title, filterTab) {
  var header = document.createElement("div");
  header.className = "statpanel-heading";

  var titleNode = document.createElement("h3");
  titleNode.className = "statpanel-heading-title";
  titleNode.textContent = title;
  header.appendChild(titleNode);

  if (filterTab) {
    var filter = document.createElement("input");
    filter.id = "statpanel-filter";
    filter.className = "statpanel-filter";
    filter.type = "text";
    filter.placeholder = "Filter...";
    filter.value = tab_search[filterTab] || "";
    filter.oninput = function () {
      tab_search[filterTab] = filter.value;
      if (filterTab == "Favorites") {
        draw_favorites();
      } else {
        draw_verbs(filterTab);
      }
      var newFilter = document.getElementById("statpanel-filter");
      if (newFilter) {
        newFilter.focus();
        newFilter.value = tab_search[filterTab] || "";
      }
    };
    header.appendChild(filter);
  }

  statcontentdiv.appendChild(header);
}

function matches_verb_filter(part, filterText) {
  if (!filterText) {
    return true;
  }
  var needle = filterText.toLowerCase();
  for (var i = 0; i < part.length; i++) {
    if (
      typeof part[i] == "string" &&
      part[i].toLowerCase().indexOf(needle) != -1
    ) {
      return true;
    }
  }
  return false;
}

function draw_verbs(cat) {
  statcontentdiv.textContent = "";
  draw_content_header(cat, cat);
  var table = document.createElement("div");
  var additions = {}; // additional sub-categories to be rendered
  table.className = "grid-container";
  sortVerbs();
  cat = normalize_tab_name(cat);
  var grouped = is_tab_grouped(cat);
  var filterText = tab_search[cat] || "";
  verbs.reverse(); // sort verbs backwards before we draw
  for (var i = 0; i < verbs.length; ++i) {
    var part = verbs[i];
    var rawName = part[0] || "";
    var name = normalize_tab_name(rawName);
    var command = part[1];

    if (
      command &&
      matches_verb_filter(part, filterText) &&
      name.lastIndexOf(cat, 0) != -1 &&
      (name.length == cat.length || name.charAt(cat.length) == ".")
    ) {
      var rawSplit = rawName.split(".");
      var subCat =
        grouped &&
        rawSplit.length > 1 &&
        !(split_admin_tabs && rawSplit[0] === "Admin")
          ? rawSplit[1]
          : null;
      if (subCat && !additions[subCat]) {
        var newTable = document.createElement("div");
        newTable.className = "grid-container";
        additions[subCat] = newTable;
      }

      var a = document.createElement("a");
      a.href = "#";
      a.onclick = make_verb_onclick(command.replace(/\s/g, "-"));
      a.oncontextmenu = make_context_menu(command);
      a.className = "grid-item";
      apply_grid_item_layout(a, cat);
      var t = document.createElement("span");
      t.textContent = command;
      t.className = "grid-item-text";
      a.appendChild(t);
      var favoriteToggle = document.createElement("span");
      favoriteToggle.className = favorites.includes(command)
        ? "grid-favorite-toggle is-favorite"
        : "grid-favorite-toggle";
      favoriteToggle.title = favorites.includes(command)
        ? "Remove from Favorites"
        : "Add to Favorites";
      favoriteToggle.onclick = make_favorite_toggle(command);
      a.appendChild(favoriteToggle);
      (subCat ? additions[subCat] : table).appendChild(a);
    }
  }

  // Append base table to view
  var content = document.getElementById("statcontent");
  content.appendChild(table);

  // Append additional sub-categories if relevant
  for (var cat in additions) {
    if (additions.hasOwnProperty(cat)) {
      // do addition here
      var header = document.createElement("h3");
      header.textContent = cat;
      content.appendChild(header);
      content.appendChild(additions[cat]);
    }
  }
}

function collect_known_tabs() {
  var known = [];
  function addKnown(name) {
    name = normalize_tab_name(name);
    if (name && !known.includes(name)) {
      known.push(name);
    }
  }

  addKnown("Status");
  addKnown("Favorites");
  addKnown("Settings");
  for (var i = 0; i < verb_tabs.length; i++) {
    addKnown(verb_tabs[i]);
  }
  for (var j = 0; j < permanent_tabs.length; j++) {
    addKnown(permanent_tabs[j]);
  }
  if (Array.isArray(tab_prefs.order)) {
    for (var k = 0; k < tab_prefs.order.length; k++) {
      addKnown(tab_prefs.order[k]);
    }
  }
  if (Array.isArray(tab_prefs.hidden)) {
    for (var h = 0; h < tab_prefs.hidden.length; h++) {
      addKnown(tab_prefs.hidden[h]);
    }
  }
  if (tab_prefs.colors) {
    for (var colorTab in tab_prefs.colors) {
      if (tab_prefs.colors.hasOwnProperty(colorTab)) {
        addKnown(colorTab);
      }
    }
  }
  known.sort(function (a, b) {
    return get_tab_order(a) - get_tab_order(b);
  });
  return known;
}

function ensure_tab_order(known) {
  if (!Array.isArray(tab_prefs.order)) {
    tab_prefs.order = [];
  }
  for (var i = 0; i < known.length; i++) {
    if (!tab_prefs.order.includes(known[i])) {
      tab_prefs.order.push(known[i]);
    }
  }
}

function move_tab_order(tabName, direction) {
  var known = collect_known_tabs();
  ensure_tab_order(known);
  var index = tab_prefs.order.indexOf(tabName);
  var nextIndex = index + direction;
  if (index < 0 || nextIndex < 0 || nextIndex >= tab_prefs.order.length) {
    return;
  }
  var swap = tab_prefs.order[nextIndex];
  tab_prefs.order[nextIndex] = tab_prefs.order[index];
  tab_prefs.order[index] = swap;
  apply_menu_order_and_colors();
  send_tab_prefs_to_byond();
  draw_statpanel_settings();
}

function set_tab_visibility(tabName, visible) {
  if (is_core_tab(tabName)) {
    return;
  }
  if (!Array.isArray(tab_prefs.hidden)) {
    tab_prefs.hidden = [];
  }
  var index = tab_prefs.hidden.indexOf(tabName);
  if (visible) {
    if (index != -1) {
      tab_prefs.hidden.splice(index, 1);
    }
    createStatusTab(tabName);
  } else {
    if (index == -1) {
      tab_prefs.hidden.push(tabName);
    }
    hideStatusTab(tabName);
    if (current_tab === tabName) {
      tab_change("Status");
    }
  }
  send_tab_prefs_to_byond();
  draw_statpanel_settings();
}

function set_tab_grouping(tabName, grouped) {
  if (!Array.isArray(tab_prefs.structured)) {
    tab_prefs.structured = collect_known_tabs();
  }
  var index = tab_prefs.structured.indexOf(tabName);
  if (grouped && index == -1) {
    tab_prefs.structured.push(tabName);
  } else if (!grouped && index != -1) {
    tab_prefs.structured.splice(index, 1);
  }
  send_tab_prefs_to_byond();
  if (current_tab === tabName) {
    draw_verbs(tabName);
  }
  draw_statpanel_settings();
}

function set_tab_button_limit(tabName, value) {
  if (!tab_prefs.max_buttons_per_row) {
    tab_prefs.max_buttons_per_row = {};
  }
  var limit = parseInt(value, 10);
  if (isNaN(limit) || limit < 1) {
    delete tab_prefs.max_buttons_per_row[tabName];
  } else {
    tab_prefs.max_buttons_per_row[tabName] = Math.min(limit, 20);
  }
  send_tab_prefs_to_byond();
  if (current_tab === tabName) {
    draw_verbs(tabName);
  }
  draw_statpanel_settings();
}

function draw_statpanel_settings() {
  statcontentdiv.textContent = "";
  draw_content_header("Statpanel", null);

  var actions = document.createElement("div");
  actions.className = "statpanel-actions";
  var fixButton = document.createElement("button");
  fixButton.className = "statpanel-fix-button";
  fixButton.textContent = "Fix Stat Panel";
  fixButton.onclick = function () {
    run_after_focus(function () {
      Byond.command("Fix-Stat-Panel");
    });
  };
  actions.appendChild(fixButton);
  statcontentdiv.appendChild(actions);

  var note = document.createElement("div");
  note.className = "statpanel-settings-note";
  note.textContent = "Configure visible tabs, order, and per-tab colors.";
  statcontentdiv.appendChild(note);

  var rows = document.createElement("div");
  rows.className = "statpanel-settings";
  var known = collect_known_tabs();
  ensure_tab_order(known);

  for (var i = 0; i < known.length; i++) {
    (function (tabName) {
      var row = document.createElement("div");
      row.className = "statpanel-settings-row";
      if (is_tab_hidden(tabName)) {
        row.className += " is-hidden";
      }

      var visible = document.createElement("button");
      visible.className = "statpanel-tab-visibility";
      visible.textContent = tabName;
      visible.title = is_core_tab(tabName)
        ? "This tab is always visible."
        : "Toggle tab visibility.";
      visible.disabled = is_core_tab(tabName);
      visible.onclick = function () {
        set_tab_visibility(tabName, is_tab_hidden(tabName));
      };
      row.appendChild(visible);

      var grouped = document.createElement("button");
      grouped.className = is_tab_grouped(tabName)
        ? "statpanel-toggle is-active"
        : "statpanel-toggle";
      grouped.textContent = "Grouped";
      grouped.onclick = function () {
        set_tab_grouping(tabName, !is_tab_grouped(tabName));
      };
      row.appendChild(grouped);

      var maxButtons = document.createElement("input");
      maxButtons.className = "statpanel-max-buttons";
      maxButtons.type = "text";
      maxButtons.placeholder = "auto";
      maxButtons.value = get_tab_button_limit(tabName) || "";
      maxButtons.title = "Maximum buttons per row. Blank means automatic.";
      maxButtons.onchange = function () {
        set_tab_button_limit(tabName, maxButtons.value);
      };
      row.appendChild(maxButtons);

      var up = document.createElement("button");
      up.className = "statpanel-order";
      up.textContent = "^";
      up.title = "Move tab left.";
      up.onclick = function () {
        move_tab_order(tabName, -1);
      };
      row.appendChild(up);

      var down = document.createElement("button");
      down.className = "statpanel-order";
      down.textContent = "v";
      down.title = "Move tab right.";
      down.onclick = function () {
        move_tab_order(tabName, 1);
      };
      row.appendChild(down);

      var color = document.createElement("input");
      color.className = "statpanel-color";
      color.type = "color";
      var current = tab_prefs.colors && tab_prefs.colors[tabName];
      color.value =
        typeof current == "string" && current.trim().length
          ? current.trim()
          : "#313131";
      color.onchange = function () {
        if (!tab_prefs.colors) {
          tab_prefs.colors = {};
        }
        tab_prefs.colors[tabName] = color.value;
        apply_tab_color(document.getElementById(tabName), tabName);
        send_tab_prefs_to_byond();
      };
      row.appendChild(color);

      var clear = document.createElement("button");
      clear.className = "statpanel-clear-color";
      clear.textContent = "x";
      clear.title = "Clear tab color.";
      clear.onclick = function () {
        if (tab_prefs.colors) {
          delete tab_prefs.colors[tabName];
        }
        apply_tab_color(document.getElementById(tabName), tabName);
        send_tab_prefs_to_byond();
        draw_statpanel_settings();
      };
      row.appendChild(clear);

      rows.appendChild(row);
    })(known[i]);
  }
  statcontentdiv.appendChild(rows);
}

function set_theme(which) {
  if (which == "light") {
    document.body.className = "";
    document.documentElement.className = "light";
  } else if (which == "dark") {
    document.body.className = "dark";
    document.documentElement.className = "dark";
  }
}

function set_font_size(size) {
  document.body.style.setProperty("font-size", size);
}

function set_tabs_style(style) {
  if (style == "default") {
    menu.classList.add("menu-wrap");
    menu.classList.remove("tabs-classic");
  } else if (style == "classic") {
    menu.classList.add("menu-wrap");
    menu.classList.add("tabs-classic");
  } else if (style == "scrollable") {
    menu.classList.remove("menu-wrap");
    menu.classList.remove("tabs-classic");
  }
}

function is_text_entry_target(target) {
  if (!target || !target.tagName) {
    return false;
  }
  var tagName = target.tagName.toLowerCase();
  return (
    tagName == "input" ||
    tagName == "textarea" ||
    tagName == "select" ||
    target.isContentEditable
  );
}

function restoreFocus(event) {
  if (
    event &&
    (is_text_entry_target(event.target) ||
      is_text_entry_target(document.activeElement))
  ) {
    return;
  }
  run_after_focus(function () {
    Byond.winset("map", {
      focus: true,
    });
  });
}

function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(";");
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == " ") c = c.substring(1);
    if (c.indexOf(name) === 0) {
      return decoder(c.substring(name.length, c.length));
    }
  }
  return "";
}

function add_verb_list(payload) {
  var to_add = payload; // list of a list with category and verb inside it
  to_add.sort(); // sort what we're adding
  for (var i = 0; i < to_add.length; i++) {
    var part = to_add[i];
    if (!part[0]) continue;
    var category = normalize_tab_name(part[0]);
    if (findVerbindex(part[1], verbs)) continue;
    if (verb_tabs.includes(category)) {
      verbs.push(part);
      if (current_tab == category) {
        draw_verbs(category); // redraw if we added a verb to the tab we're currently in
      }
    } else if (category) {
      verb_tabs.push(category);
      verbs.push(part);
      createStatusTab(category);
    }
  }
}

document.addEventListener("mouseup", restoreFocus);
document.addEventListener("keyup", restoreFocus);

addPermanentTab("Favorites");
addPermanentTab("Settings");

if (!current_tab) {
  addPermanentTab("Status");
  tab_change("Status");
}

window.onload = function () {
  Byond.sendMessage("Update-Verbs");
};

Byond.subscribeTo("update_favorites", update_favorites);

Byond.subscribeTo("remove_verb_list", function (v) {
  var to_remove = v;
  for (var i = 0; i < to_remove.length; i++) {
    remove_verb(to_remove[i]);
  }
  check_verbs();
  sortVerbs();
  if (verb_tabs.includes(current_tab)) draw_verbs(current_tab);
});

// passes a 2D list of (verbcategory, verbname) creates tabs and adds verbs to respective list
// example (IC, Say)
Byond.subscribeTo("init_verbs", function (payload) {
  wipe_verbs(); // remove all verb categories so we can replace them
  checkStatusTab(); // remove all status tabs
  if (payload && payload.tab_prefs) {
    tab_prefs.order = Array.isArray(payload.tab_prefs.order)
      ? payload.tab_prefs.order.slice()
      : [];
    tab_prefs.hidden = Array.isArray(payload.tab_prefs.hidden)
      ? payload.tab_prefs.hidden.slice()
      : [];
    tab_prefs.colors =
      payload.tab_prefs.colors && typeof payload.tab_prefs.colors == "object"
        ? payload.tab_prefs.colors
        : {};
    tab_prefs.structured = Array.isArray(payload.tab_prefs.structured)
      ? payload.tab_prefs.structured.slice()
      : null;
    tab_prefs.max_buttons_per_row =
      payload.tab_prefs.max_buttons_per_row &&
      typeof payload.tab_prefs.max_buttons_per_row == "object"
        ? payload.tab_prefs.max_buttons_per_row
        : {};
  }
  verb_tabs = normalize_tab_list(payload.panel_tabs);
  verb_tabs.sort(); // sort it
  var do_update = false;
  var cat = "";
  for (var i = 0; i < verb_tabs.length; i++) {
    cat = verb_tabs[i];
    createStatusTab(cat); // create a category if the verb doesn't exist yet
  }
  if (verb_tabs.includes(current_tab)) {
    do_update = true;
  }
  if (payload.verblist) {
    add_verb_list(payload.verblist);
    sortVerbs(); // sort them
    if (do_update) {
      draw_verbs(current_tab);
    }
  }
  if (payload.favorites) {
    update_favorites(payload.favorites);
  }
  apply_menu_order_and_colors();
  SendTabsToByond();
});

Byond.subscribeTo("update_stat", function (payload) {
  status_tab_parts = [payload.ping_str];

  var parsed = payload.global_data;

  for (var i = 0; i < parsed.length; i++)
    if (parsed[i] != null) status_tab_parts.push(parsed[i]);

  parsed = payload.other_str;

  for (var i = 0; i < parsed.length; i++)
    if (parsed[i] != null) status_tab_parts.push(parsed[i]);

  if (current_tab == "Status") {
    draw_status();
  } else if (current_tab == "Debug Stat Panel") {
    draw_debug();
  }
});

Byond.subscribeTo("update_mc", function (payload) {
  mc_tab_parts = payload.mc_data;
  mc_tab_parts.splice(0, 0, ["", "Location:", payload.coord_entry]);

  if (!verb_tabs.includes("MC")) {
    verb_tabs.push("MC");
  }

  createStatusTab("MC");

  if (current_tab == "MC") {
    draw_mc();
  }
});

Byond.subscribeTo("create_debug", function () {
  if (!document.getElementById("Debug Stat Panel")) {
    addPermanentTab("Debug Stat Panel");
  } else {
    removePermanentTab("Debug Stat Panel");
  }
});

Byond.subscribeTo("create_listedturf", function (TN) {
  remove_listedturf(); // remove the last one if we had one
  turfname = TN;
  addPermanentTab(turfname);
  tab_change(turfname);
});

Byond.subscribeTo("remove_admin_tabs", function () {
  href_token = null;
  remove_mc();
  remove_tickets();
  remove_sdql2();
  remove_interviews();
});

Byond.subscribeTo("update_listedturf", function (TC) {
  turfcontents = TC;
  if (current_tab == turfname) {
    draw_listedturf();
  }
});

Byond.subscribeTo("update_interviews", function (I) {
  interviewManager = I;
  if (current_tab == "Tickets") {
    draw_interviews();
  }
});

Byond.subscribeTo("update_split_admin_tabs", function (status) {
  status = status == true;

  if (split_admin_tabs !== status) {
    if (split_admin_tabs === true) {
      removeStatusTab("Events");
      removeStatusTab("Fun");
      removeStatusTab("Game");
    }
    split_admin_tabs = status;
    update_verbs();
  }
  split_admin_tabs = status;
});

Byond.subscribeTo("add_admin_tabs", function (ht) {
  href_token = ht;
  addPermanentTab("MC");
  addPermanentTab("Tickets");
});

Byond.subscribeTo("update_sdql2", function (S) {
  sdql2 = S;
  if (sdql2.length > 0 && !verb_tabs.includes("SDQL2")) {
    verb_tabs.push("SDQL2");
    addPermanentTab("SDQL2");
  }
  if (current_tab == "SDQL2") {
    draw_sdql2();
  }
});

Byond.subscribeTo("update_tickets", function (T) {
  tickets = T;
  if (!verb_tabs.includes("Tickets")) {
    verb_tabs.push("Tickets");
    addPermanentTab("Tickets");
  }
  if (current_tab == "Tickets") {
    draw_tickets();
  }
});

Byond.subscribeTo("remove_listedturf", remove_listedturf);

Byond.subscribeTo("remove_sdql2", remove_sdql2);

Byond.subscribeTo("remove_mc", remove_mc);

Byond.subscribeTo("add_verb_list", add_verb_list);
