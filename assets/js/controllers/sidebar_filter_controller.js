import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';

export default class extends Controller {
  visible = false;
  selectors = {};

  connect() {
    this.element.addEventListener('click', this.openFilter);
    this.initData();
  }

  initData = () => {
    const filters = Array.from(this.element.parentNode.querySelectorAll('.s2m-filter--select'));

    this.selectors = filters.map((selector) => {
      const id = selector.getAttribute('id');
      const label = this.element.parentNode.querySelector(`label[for=${id}]`).textContent;
      const options = Array.from(selector.querySelectorAll('option'));

      return {
        id,
        label,
        options,
      };
    });
  };

  openFilter = (event) => {
    event.preventDefault();
    if (!this.visible) {
      document.body.style.overflow = 'hidden';
      this.visible = true;
      render(this.renderFilter(), this.element.parentNode);
    }
  };

  hideFilter = (event) => {
    event.preventDefault();
    if (this.visible) {
      document.body.style.overflow = 'auto';
      this.element.parentNode.querySelector('.s2m-sidebar-filter').remove();
      this.visible = false;
    }
  };

  backgroundClicked = (event) => {
    if (event.target == event.currentTarget) {
      this.hideFilter(event);
    }
  };

  getCheckboxId = (option) => {
    return `js-checkbox-${option.value}`;
  };

  getClassName = (option) => {
    return `js-checkbox-color-${option.value.toLowerCase()}`;
  };

  toggleCheckbox = (event) => {
    const option = this.element.parentNode.querySelector(`option[value="${event.target.getAttribute('data-target')}"]`);
    if (event.target.checked) {
      option.setAttribute('selected', 'selected');
    } else {
      option.removeAttribute('selected');
    }
    option.parentNode.dispatchEvent(new Event('change'));
  };

  renderFilter = () => {
    return (
      <div class="s2m-sidebar-filter" onClick={this.backgroundClicked}>
        <div class="s2m-sidebar-filter--list">
          <div class="s2m-sidebar-filter--headline">
            <span>Filter wählen...</span>
            <button
              type="button"
              class="s2m-sidebar-filter--close"
              onClick={this.hideFilter}
              aria-label="Auswahl schließen">
              <i class="fa fa-close"></i>
            </button>
          </div>

          <div class="s2m-sidebar-filter--areas">
            {this.selectors.map((item) => {
              return (
                <div class="s2m-sidebar-filter--area">
                  <div class="s2m-sidebar-filter--label">{item.label}</div>

                  <div class="s2m-sidebar-filter--options">
                    {item.options.map((option) => (
                      <div class="s2m-sidebar-filter--options-row">
                        <input
                          type="checkbox"
                          id={this.getCheckboxId(option)}
                          onChange={this.toggleCheckbox}
                          data-target={option.value}
                          checked={option.hasAttribute('selected')}
                        />
                        <label for={this.getCheckboxId(option)} class={this.getClassName(option)}>
                          {option.innerText}
                        </label>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    );
  };
}
