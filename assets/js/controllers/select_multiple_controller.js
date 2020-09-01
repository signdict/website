import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';

export default class extends Controller {
  connect() {
    this.options = Array.from(this.element.querySelectorAll('.s2m-filter--select option'));
    this.label = this.element.querySelector('.s2m-filter--label');
    this.label.style.display = 'none';
    this.element.classList.remove('s2m-select-multiple');
    this.element.classList.add('js-select-multiple');
    this.cleanUp();
    render(this.renderDropdown(), this.element);
    this.element.querySelector('select').style.display = 'none';
    this.setOptionsVisible(false);

    const select = this.element.querySelector('select');
    select.style.display = 'none';
    select.addEventListener('change', this.loadValues);
    this.synchValues();

    document.addEventListener('click', this.documentClick);
    document.addEventListener('keydown', this.documentKeydown);
  }

  cleanUp = () => {
    const dropdown = this.element.querySelector('.js-select-multiple-dropdown');
    if (dropdown) {
      this.element.querySelector('.js-select-multiple-dropdown').remove();
    }
  };

  documentKeydown = (event) => {
    if (event.key === 'Escape' && this.optionsVisible && !this.element.contains(event.target)) {
      this.setOptionsVisible(false);
    }
  };

  documentClick = (event) => {
    if (this.optionsVisible && !this.element.contains(event.target)) {
      event.preventDefault();
      this.setOptionsVisible(false);
    }
  };

  loadValues = () => {
    this.options.forEach((option) => {
      this.element.querySelector(`#${this.getCheckboxId(option)}`).checked = option.hasAttribute('selected');
    });
  };

  synchValues = () => {
    this.options.forEach((option) => {
      this.element.querySelector(`#${this.getCheckboxId(option)}`).checked = option.selected;
      if (option.selected) {
        option.setAttribute('selected', 'selected');
      } else {
        option.removeAttribute('selected');
      }
    });
    this.element.querySelector('select').dispatchEvent(new Event('change'));
  };

  toggleCheckbox = (event) => {
    const option = this.element.querySelector(`option[value="${event.target.getAttribute('data-target')}"]`);
    if (event.target.checked) {
      option.setAttribute('selected', 'selected');
    } else {
      option.removeAttribute('selected');
    }
    this.element.querySelector('select').dispatchEvent(new Event('change'));
  };

  getCheckboxId = (option) => {
    return `js-checkbox-${option.value}`;
  };

  getClassName = (option) => {
    return `js-checkbox-color-${option.value.toLowerCase()}`;
  };

  toggleDropDown = () => {
    this.setOptionsVisible(!this.optionsVisible);
  };

  setOptionsVisible = (visible) => {
    this.optionsVisible = visible;
    const el = this.element.querySelector('.js-select-multiple--options');
    if (visible) {
      this.element.classList.add('js-select-multiple--title--opened');
      el.style.display = 'block';
    } else {
      this.element.classList.remove('js-select-multiple--title--opened');
      el.style.display = 'none';
    }
  };

  renderDropdown = () => {
    return (
      <div class="js-select-multiple-dropdown">
        <button type="button" class="js-select-multiple--title" onClick={this.toggleDropDown}>
          <div class="js-select-multiple--text">{this.label.innerText}</div>
          <div class="js-select-multiple--arrow">
            <svg width="17" height="8" viewBox="0 0 17 8">
              <path d="M8.5,0,17,8H0Z" transform="translate(17 8) rotate(180)" fill="#707070" />
            </svg>
          </div>
        </button>
        <div class="js-select-multiple--options">
          {this.options.map((option) => (
            <div class="js-select-multiple--options-row">
              <input
                type="checkbox"
                id={this.getCheckboxId(option)}
                onChange={this.toggleCheckbox}
                data-target={option.value}
              />
              <label for={this.getCheckboxId(option)} class={this.getClassName(option)}>
                {option.innerText}
              </label>
            </div>
          ))}
        </div>
      </div>
    );
  };
}
