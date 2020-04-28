import i18next from 'i18next';
import I18nXHR from 'i18next-xhr-backend';
import i18nDE from './i18n/de.js';
import i18nEN from './i18n/en.js';

const i18n = i18next.use(I18nXHR).init(
  {
    fallbackLng: 'en',
    whitelist: ['en', 'de'],
    lng: document.documentElement.lang,
    preload: [document.documentElement.lang],
    debug: false,
    detection: {
      order: ['htmlTag'],
      lookupQuerystring: 'lang',
    },
    resources: {
      en: {
        translation: i18nEN,
      },
      de: {
        translation: i18nDE,
      },
    },
  },
  function (err, t) {
    if (err) return console.error(err);
  }
);

export {i18n, i18next};
