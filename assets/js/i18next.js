import i18next from 'i18next';
import i18nDE from './i18n/de.js';
import i18nEN from './i18n/en.js';

// All translations are bundled, so no backend plugin is needed to load them.
const i18n = i18next.init(
  {
    fallbackLng: 'en',
    supportedLngs: ['en', 'de'],
    lng: document.documentElement.lang,
    debug: false,
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
