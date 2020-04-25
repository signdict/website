import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';

const CACHE_DURATION = 10 * 60 * 1000; // Cache for 10 minutes

export default class extends Controller {
  connect() {
    this.cache = {};
    this.currentResults = [];
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
      const items = this.getFromCache(this.element.value);
      if (items) {
        this.displayResults(items);
      } else {
        this.timeout = window.setTimeout(this.doSearch, 200);
      }
    }
  };

  showPopup = () => {
    if (this.currentResults && this.currentResults.length > 0) {
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
    this.currentResults = [];
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
          const items = this.filterEmptyResults(result.data.search).slice(0, 5);
          if (items.length > 0) {
            this.addToCache(searchValue, items);
            this.displayResults(items);
          } else {
            this.resetSearch();
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

  displayResults = (results) => {
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
                  <span className="so-search-hints--item--text">{item.text}</span>
                </a>
              </li>
            );
          })}
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

  addToCache = (searchTerm, items) => {
    this.cache[searchTerm] = {
      time: new Date(),
      items,
    };
  };

  getFromCache = (searchTerm) => {
    const cacheEntry = this.cache[searchTerm];
    if (cacheEntry && cacheEntry.time > new Date() - CACHE_DURATION) {
      return cacheEntry.items;
    }
  };
}
