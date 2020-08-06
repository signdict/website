import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';

export default class extends Controller {
  static targets = ['button', 'filterbar'];

  connect() {
    this.showFilterbar(false);
    this.buttonTarget.addEventListener('click', this.toggleFilterbar);

    const selects = this.element.querySelectorAll('select');

    selects.forEach((select) => {
      select.addEventListener('change', this.updateButtonStatus, false);
    });

    this.updateButtonStatus();
  }

  updateButtonStatus = () => {
    const selects = this.element.querySelectorAll('select');
    let filterActive = false;

    selects.forEach((select) => {
      if (select.querySelectorAll('option[selected]').length > 0) {
        filterActive = true;
      }
    });

    if (filterActive) {
      this.buttonTarget.classList.add('s2m-searchbar--filtertoggle--active');
    } else {
      this.buttonTarget.classList.remove('s2m-searchbar--filtertoggle--active');
    }
  };

  toggleFilterbar = () => {
    this.showFilterbar(!this.filterbarVisible);
  };

  showFilterbar = (showBar) => {
    this.filterbarVisible = showBar;
    if (showBar) {
      this.filterbarTarget.style.display = null;
    } else {
      this.filterbarTarget.style.display = 'none';
    }
  };
}
