import {Controller} from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('click', this.openPage);
  }

  openPage = () => {
    window.location.href = this.data.get('href');
  };
}
