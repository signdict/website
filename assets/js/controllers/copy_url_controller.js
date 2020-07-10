import {Controller} from 'stimulus';
import jsxElem, {render} from 'jsx-no-react';
import {i18next, i18n} from '../i18next.js';

export default class extends Controller {
  connect() {
    console.log(this.element);

    render(this.createHtml(), this.element);
  }

  copyUrl = () => {
    console.log('copy url');
    const listener = (e) => {
      e.clipboardData.setData('text/plain', this.data.get('link'));
      e.preventDefault();
    };
    document.addEventListener('copy', listener);
    document.execCommand('copy');
    document.removeEventListener('copy', listener);
  };

  createHtml = () => {
    return (
      <button onClick={this.copyUrl}>
        <i class="fa fa-copy"></i>
        {i18next.t('Copy URL')}
      </button>
    );
  };
}
