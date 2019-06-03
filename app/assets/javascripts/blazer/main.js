Vue.config.devtools = false
Vue.config.productionTip = false

$(document).on('mouseenter', '.dropdown-toggle', function () {
  $(this).parent().addClass('open')
})

$(document).on("change", "#bind input, #bind select", function () {
  submitIfCompleted($(this).closest("form"))
})

$(document).on("click", "#code", function () {
  $(this).addClass("expanded")
})

$(document).on("click", "a.click2CopyTable", function (event) {
  event.preventDefault();
  var selector = $(this).attr('href');
  copyToClipboard(selector)
})

$(document).on("mouseover", "table th[data-popup]", function (event) {
  var sum = 0, numbers = [];
  var columns = $(this).parents('thead').find('th');
  var columnIndex = columns.index(this) + 1;
  var cells = $(this).parents('table').find('tbody tr td:nth-child('+columnIndex+')');
  cells.each(function(index, cell) {
    content = $(cell).text();
    content = content.split(',').join('');
    float = parseFloat(content);
    if (isNaN(float)) float = 0;
    numbers.push(float);
    sum += float
  });
  sum = parseFloat(sum.toFixed(2));
  showTooltip({
    el: this,
    min: Math.min.apply(null, numbers),
    max: Math.max.apply(null, numbers),
    avg: parseFloat((sum / cells.length).toFixed(2)),
    sum: sum,
    count: cells.length
  })
})

$(document).on("mouseleave", "table th[data-popup]", function (event) {
  $('#summanyPopup').remove();
})

function submitIfCompleted($form) {
  var completed = true
  $form.find("input[name], select").each( function () {
    if ($(this).val() == "") {
      completed = false
    }
  })
  if (completed) {
    $form.submit()
  }
}

// Prevent backspace from navigating backwards.
// Adapted from Biff MaGriff: http://stackoverflow.com/a/7895814/1196499
function preventBackspaceNav() {
  $(document).keydown(function (e) {
    var preventKeyPress
    if (e.keyCode == 8) {
      var d = e.srcElement || e.target
      switch (d.tagName.toUpperCase()) {
        case 'TEXTAREA':
          preventKeyPress = d.readOnly || d.disabled
          break
        case 'INPUT':
          preventKeyPress = d.readOnly || d.disabled || (d.attributes["type"] && $.inArray(d.attributes["type"].value.toLowerCase(), ["radio", "reset", "checkbox", "submit", "button"]) >= 0)
          break
        case 'DIV':
          preventKeyPress = d.readOnly || d.disabled || !(d.attributes["contentEditable"] && d.attributes["contentEditable"].value == "true")
          break
        default:
          preventKeyPress = true
          break
      }
    }
    else {
      preventKeyPress = false
    }

    if (preventKeyPress) {
      e.preventDefault()
    }
  })
}

function copyToClipboard(selector) {
  $(selector).find('.text-muted').hide();
  var el = $(selector)[0];
  var body = document.body, range, sel;
  if (document.createRange && window.getSelection) {
    range = document.createRange();
    sel = window.getSelection();
    sel.removeAllRanges();
    try {
      range.selectNodeContents(el);
      sel.addRange(range);
    } catch (e) {
      range.selectNode(el);
      sel.addRange(range);
    }
    document.execCommand("copy");
    sel.removeAllRanges();
  } else if (body.createTextRange) {
    range = body.createTextRange();
    range.moveToElementText(el);
    range.select();
    range.execCommand("Copy");
    sel.removeAllRanges();
  }
  $(selector).find('.text-muted').show();
}

function showTooltip(data) {
  var position = $(data.el).weOffset();
  var top = position.top + 20 + $(data.el).height();
  var left = position.left - 100 + $(data.el).width() / 2;
  var tooltipEl = $('#summanyPopup');
  if (tooltipEl.length == 0) {
    tooltipEl = $('<div/>').attr('id', 'summanyPopup').appendTo('body');
  }
  tooltipEl.css({ top: top, left: left }).html('');
  $('<p/>').html('Count: <span>' + formatNumber(data.count) + '</span>').appendTo(tooltipEl);
  $('<p/>').html('Min: <span>' + formatNumber(data.min) + '</span>').appendTo(tooltipEl);
  $('<p/>').html('Max: <span>' + formatNumber(data.max) + '</span>').appendTo(tooltipEl);
  $('<p/>').html('Avg: <span>' + formatNumber(data.avg) + '</span>').appendTo(tooltipEl);
  $('<p/>').html('Sum: <span>' + formatNumber(data.sum) + '</span>').appendTo(tooltipEl);
}

function formatNumber(num) {
  return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
}

preventBackspaceNav()
