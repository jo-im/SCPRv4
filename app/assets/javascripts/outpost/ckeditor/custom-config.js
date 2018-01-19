$(function() {

  // For Flatpages
  $('.cke-editor-permissive').ckeditor({
    allowedContent: true
  });

  // For news content.
  $('.cke-editor-restrictive').ckeditor({
    extraAllowedContent: [
      "a[*](*)",
      "img[*](*){*}",
      "strong",
      "em",
      "small",
      "u",
      "s",
      "i",
      "b",
      "blockquote",
      "div[*](*){*}",
      "ul",
      "ol",
      "li",
      "hr",
      "h1",
      "h2",
      "h3",
      "h4",
      "h5",
      "h6",
      "script[src,charset,async]",
      "iframe[*](*){*}",
      "embed[*]",
      "object[*]",
      "cite",
      "mark",
      "time",
      "dd",
      "dl",
      "dt",
      "table",
      "th",
      "tr",
      "td",
      "tbody",
      "thead",
      "tfoot"
    ].join(";")
  });

  // For abstract fields.
  $('.cke-editor-basic').ckeditor({
    extraAllowedContent: [
      "strong",
      "b",
      "ul",
      "li"
    ].join(";")
  });

});
