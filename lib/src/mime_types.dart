enum MIMEType {
  application_json,
  multipart_form_data,
  text_plain,
  application_x_www_form_urlencoded,
  nil
}

String mimeTypeValue(MIMEType type) {
  switch (type) {
    case MIMEType.application_json:
      {
        return "application/json";
      }
      break;
    case MIMEType.multipart_form_data:
      {
        return "multipart/form-data";
      }
      break;
    case MIMEType.text_plain:
      {
        return "text/plain";
      }
      break;
    case MIMEType.application_x_www_form_urlencoded:
      {
        return "application/x-www-form-urlencoded";
      }
      break;
    case MIMEType.nil:
      {
        return "";
      }
      break;
  }

  return "";
}
