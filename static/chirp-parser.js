(function () {
  var ChirpParser = window.ChirpParser = window.ChirpParser || {};

  ChirpParser.CHAR_BAG = [",", ".", ":", ";", "!", "\"", "'", " "];

  ChirpParser.cleanString = function (string) {
    var i = 1;

    while (string[i] && ChirpParser.CHAR_BAG.indexOf(string[i]) < 0) {
      i++;
    }

    return [string.slice(1, i), string.slice(i)];
  };

  ChirpParser.makeLink = function (string) {
    var [text, rest] = ChirpParser.cleanString(string);
    var marker = string[0];
    switch (marker) {
    case "@":
      return "<a href='#/users/" + text + "'>" + marker + text + "</a>" + rest;
      break;
    case "#":
      return "<a href='#/tags/" + text + "'>" + marker + text + "</a>" + rest;
      break;
    default:
      return string;
    }
  };

  ChirpParser.parse = function (content) {
    return content.split(' ').map(ChirpParser.makeLink).join(' ');
  };

})();
