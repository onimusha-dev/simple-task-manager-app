String getSubString(String text, int length) {
  if (text.length <= length) return text;
  return text.substring(0, length);
}
