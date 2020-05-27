import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';
import {i18next, i18n} from '../i18next.js';

const CACHE_DURATION = 10 * 60 * 1000; // Cache for 10 minutes

export default class extends Controller {
  connect() {
    this.cache = {};
    this.currentResults = null;
    this.element.setAttribute('autocomplete', 'off');
    this.element.addEventListener('input', this.resetTimer);
    this.element.addEventListener('focus', () => {
      this.showPopup();
    });
    document.addEventListener('focusin', (event) => {
      if (!this.element.parentElement.contains(event.target)) {
        this.hidePopup();
      }
    });
    document.addEventListener('click', (event) => {
      if (!this.element.parentElement.contains(event.target)) {
        this.hidePopup();
      }
    });
  }

  resetTimer = () => {
    if (this.timeout) {
      window.clearTimeout(this.timeout);
    }
    if (this.element.value.length == 0) {
      this.resetSearch();
    } else {
      const entry = this.getFromCache(this.element.value);
      if (entry) {
        this.displayResults(entry.items, entry.hasMore);
      } else {
        this.timeout = window.setTimeout(this.doSearch, 200);
      }
    }
  };

  showPopup = () => {
    if (this.currentResults) {
      const searchPopup = this.findOrCreatePopup();
      searchPopup.style.width = this.element.getBoundingClientRect().width + 'px';
      searchPopup.style.display = 'block';
      this.element.classList.add('so-searchbar--input--with-border');
    }
  };

  hidePopup = () => {
    const searchPopup = this.findOrCreatePopup();
    searchPopup.style.display = 'none';
    this.element.classList.remove('so-searchbar--input--with-border');
    window.clearTimeout(this.timeout);
  };

  resetSearch = () => {
    const searchPopup = this.findOrCreatePopup();
    searchPopup.innerHTML = '';
    this.currentResults = null;
    this.hidePopup();
  };

  doSearch = () => {
    const searchValue = this.element.value;
    fetch('/graphql-api', {
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      method: 'POST',
      credentials: 'same-origin',
      body: JSON.stringify({
        query: `
          query aSearch($search: String!) {
            search(word: $search) {
              text
              description
              url
              currentVideo {
                thumbnailUrl
              }
            }
          }
        `,
        operationName: 'aSearch',
        variables: {search: searchValue},
      }),
    }).then((result) => {
      if (this.element.value == searchValue && result.status === 200) {
        result.json().then((result) => {
          const hasMore = result.data.search.length > 5;
          const items = this.filterEmptyResults(result.data.search).slice(0, 5);
          if (items.length > 0) {
            this.addToCache(searchValue, items, hasMore);
            this.displayResults(items, hasMore);
          } else {
            this.showHint();
          }
        });
      }
    });
  };

  filterEmptyResults = (results) => {
    return results.filter((item) => {
      return item.currentVideo.thumbnailUrl && item.currentVideo.thumbnailUrl.length > 0;
    });
  };

  displayResults = (results, hasMore) => {
    this.currentResults = results;
    const searchPopup = this.findOrCreatePopup();
    searchPopup.innerHTML = '';
    render(
      <div>
        <ul className="so-search-hints--list">
          {results.map((item) => {
            return (
              <li className="so-search-hints--item">
                <a className="so-search-hints--item--link" href={item.url}>
                  <img
                    className="so-search-hints--item--image"
                    src={item.currentVideo.thumbnailUrl}
                    aria-hidden="true"
                  />
                  <div className="so-search-hints--item--text">
                    {item.text}{' '}
                    {item.description.length > 0 && (
                      <span className="so-search-hitns--item--text--description">({item.description})</span>
                    )}
                  </div>
                </a>
              </li>
            );
          })}
          {hasMore && (
            <li className="so-search-hints--more">
              <a className="so-search-hints--more--link" href={`/search?q=${encodeURIComponent(this.element.value)}`}>
                {i18next.t('More')}...
              </a>
            </li>
          )}
        </ul>
      </div>,
      searchPopup
    );
    if (this.element == document.activeElement) {
      this.showPopup();
    }
  };

  findOrCreatePopup = () => {
    let popup = this.element.parentElement.querySelector('.so-search-hints');
    if (popup == null) {
      popup = document.createElement('div');
      popup.classList.add('so-search-hints');
      this.element.insertAdjacentElement('afterend', popup);
    }
    return popup;
  };

  addToCache = (searchTerm, items, hasMore) => {
    this.cache[searchTerm] = {
      time: new Date(),
      items,
      hasMore,
    };
  };

  getFromCache = (searchTerm) => {
    const cacheEntry = this.cache[searchTerm];
    if (cacheEntry && cacheEntry.time > new Date() - CACHE_DURATION) {
      return cacheEntry;
    }
  };

  raw = (string) => {
    const htmlCollection = new DOMParser().parseFromString(string, 'text/html').body.childNodes;
    const array = [].slice.call(htmlCollection);
    return array;
  };

  showHint = () => {
    this.currentResults = [];
    const searchPopup = this.findOrCreatePopup();
    searchPopup.innerHTML = '';
    render(
      <div className="so-search-hints--empty">
        {this.raw(
          i18next.t('SearchController.WordNotFound', {
            where: '/suggestion?word=' + encodeURIComponent(this.element.value),
            interpolation: {escapeValue: false},
          })
        )}
      </div>,
      searchPopup
    );
    if (this.element == document.activeElement) {
      this.showPopup();
    }
  };
}
