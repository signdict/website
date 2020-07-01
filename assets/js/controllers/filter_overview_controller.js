import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';

export default class extends Controller {
  connect() {
    setTimeout(this.initView, 200);
  }

  initView = () => {
    this.checkboxes = Array.from(document.querySelectorAll(`.${this.data.get('source')} input[type="checkbox"]`));
    this.checkboxes.forEach((item) => {
      item.addEventListener('change', this.refreshItems);
    });

    const options = Array.from(document.querySelectorAll(`.${this.data.get('source')} option`));
    this.optionNames = options.reduce(function (map, option) {
      map[option.value] = option.innerText;
      return map;
    }, {});

    this.refreshItems();
  };

  refreshItems = () => {
    this.element.innerHTML = '';
    render(this.renderFilter(), this.element);
  };

  removeItem = (item) => {
    if (item.checked) {
      item.click();
    }
  };

  resetFilter = () => {
    this.checkboxes.forEach((item) => {
      this.removeItem(item);
    });
  };

  renderFilter = () => {
    const selected = this.checkboxes.filter((item) => item.checked);

    if (selected.length == 0) {
      return <div />;
    }

    return (
      <div class="s2m-filter-overview">
        <div class="s2m-filter-overview--title">Ausgewählte Filter:</div>
        <div class="s2m-filter-overview--list">
          {selected.map((item) => {
            return (
              <div class="s2m-filter-overview--item">
                {this.optionNames[item.getAttribute('data-target')]}
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
