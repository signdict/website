import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';

export default class extends Controller {
  connect() {
    setTimeout(this.initView, 200);
  }

  initView = () => {
    const selects = Array.from(document.querySelectorAll(`.${this.data.get('source')} select`));
    selects.forEach((item) => {
      item.addEventListener('change', this.refreshItems);
    });

    this.options = Array.from(document.querySelectorAll(`.${this.data.get('source')} option`));
    this.options.forEach((item) => {
      item.addEventListener('change', this.refreshItems);
    });

    this.refreshItems();
  };

  refreshItems = () => {
    this.element.innerHTML = '';
    render(this.renderFilter(), this.element);
  };

  removeItem = (item) => {
    item.removeAttribute('selected');
    item.parentNode.dispatchEvent(new Event('change'));
  };

  resetFilter = () => {
    this.options.forEach((item) => {
      this.removeItem(item);
    });
  };

  renderFilter = () => {
    const selected = this.options.filter((item) => item.getAttribute('selected'));

    if (selected.length == 0) {
      return <div />;
    }

    return (
      <div class="s2m-filter-overview">
        <div class="s2m-filter-overview--title">Ausgewählte Filter:</div>
        <div class="s2m-filter-overview--list">
          {selected.map((item) => {
            return (
              <div class={`s2m--colors--${item.getAttribute('value').toLowerCase()} s2m-filter-overview--item`}>
                {item.innerText}
                <button
                  type="button"
                  class="s2m-filter-overview--item--remove"
                  onClick={() => this.removeItem(item)}
                  aria-label="Entfernen">
                  <svg width="14" height="14" viewBox="0 0 14 14">
                    <rect id="Box" width="14" height="14" fill="none"></rect>
                    <path
                      id="Icon_Cancel_Dark"
                      data-name="Icon / Cancel / Dark"
                      d="M151.389-13.6l-.989.989-2.511-2.511-2.511,2.511-.989-.989,2.511-2.511-2.511-2.511.989-.989,2.511,2.511,2.511-2.511.989.989-2.511,2.511Zm-3.5-9.511a7,7,0,0,0-7,7,7,7,0,0,0,7,7,7,7,0,0,0,7-7,7,7,0,0,0-7-7Z"
                      transform="translate(-140.889 23.111)"
                      fill="#b89f12"
                      fill-rule="evenodd"></path>
                  </svg>
                </button>
              </div>
            );
          })}
        </div>
        <div class="s2m-filter-overview--reset">
          <button type="button" onClick={this.resetFilter}>
            Alle Filter löschen
          </button>
        </div>
      </div>
    );
  };
}
