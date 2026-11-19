import * as i18n from '../core/i18n/i18n.js';
import * as UI from '../ui/legacy/legacy.js';

const UIStrings = {
  cssEnvironment: 'CSS Environment',
  showCssEnvironment: 'Show CSS Environment',
};
const str_ = i18n.i18n.registerUIStrings('znix/environment-meta.js', UIStrings);
const i18nString = i18n.i18n.getLazilyComputedLocalizedString.bind(undefined, str_);

let environmentModule;
async function loadEnvironmentModule() {
  environmentModule ||= await import('./environment.js');
  return environmentModule;
}

UI.ViewManager.registerViewExtension({
  location: 'panel',
  id: 'znix-css-environment',
  title: i18nString(UIStrings.cssEnvironment),
  commandPrompt: i18nString(UIStrings.showCssEnvironment),
  persistence: 'permanent',
  order: 100,
  async loadView() {
    return (await loadEnvironmentModule()).EnvironmentPanel.instance();
  },
});
