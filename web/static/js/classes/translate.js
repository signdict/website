import translations from "../i18n/map"

function translate(string) {
  let locale = document.documentElement.lang;
  let translated = translations[locale][string];
  if (translated) {
    return translated;
  } else {
    return string;
  }
}

export default translate;
