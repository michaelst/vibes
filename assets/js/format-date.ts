import { html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { DateTime } from "luxon";

@customElement('format-date')
export default class FormatDate extends LitElement {
  @property()
  date: string;

  @property()
  format: string;


  render() {
    const dt = DateTime.fromISO(this.date);

    let format;

    switch (this.format) {
      case 'relative':
        return html`
          ${dt.toRelative()}
        `

      case 'date':
        format = DateTime.DATE_MED;

        return html`
          ${dt.toLocaleString(format)} (${dt.toRelative()})
        `

      default:
        format = DateTime.DATETIME_MED_WITH_SECONDS;

        return html`
          ${dt.toLocaleString(format)} (${dt.toRelative()})
        `
    }
  }
}