/**
 * @jest-environment jsdom
 */

describe('Shortcut Key Script', () => {
  let originalPlatform;
  let originalReadyState;

  beforeAll(() => {
    originalPlatform = navigator.platform;
    originalReadyState = document.readyState;
  });

  beforeEach(() => {
    document.body.innerHTML = '';
    jest.resetModules();
  });

  afterEach(() => {
    Object.defineProperty(navigator, 'platform', {
      value: originalPlatform,
      configurable: true
    });
    Object.defineProperty(document, 'readyState', {
      value: originalReadyState,
      configurable: true
    });
    // Remove event listeners added by the script to avoid side effects
    // Since we can't easily remove anonymous functions, jest.resetModules() helps,
    // but the document event listener might persist across tests if we don't clear the document.
    // In JSDOM, replacing the document or using cloneNode might be needed if events leak.
  });

  const loadScript = () => {
    require('./shortcut-key.js');
  };

  test('should update shortcut key to Mac command key if on Mac and readyState is interactive', () => {
    Object.defineProperty(navigator, 'platform', {
      value: 'MacIntel',
      configurable: true
    });

    document.body.innerHTML = `
      <div id="search-toggle">
        <a class="nav-link">ctrl k</a>
      </div>
    `;

    loadScript();

    Object.defineProperty(document, 'readyState', {
      value: 'interactive',
      configurable: true
    });
    document.dispatchEvent(new Event('readystatechange'));

    const shortcutKeyElement = document.querySelector('#search-toggle .nav-link');
    // Using string matching because JSDOM might parse the HTML entities
    expect(shortcutKeyElement.innerHTML).toContain('k <i class="ti ti-search"></i>');
    // To be precise, check if it contains the unicode symbol or the entity
    expect(shortcutKeyElement.innerHTML).toMatch(/(&#x2318;|⌘)/);
  });

  test('should not update shortcut key if not on Mac', () => {
    Object.defineProperty(navigator, 'platform', {
      value: 'Win32',
      configurable: true
    });

    document.body.innerHTML = `
      <div id="search-toggle">
        <a class="nav-link">ctrl k</a>
      </div>
    `;

    loadScript();

    Object.defineProperty(document, 'readyState', {
      value: 'interactive',
      configurable: true
    });
    document.dispatchEvent(new Event('readystatechange'));

    const shortcutKeyElement = document.querySelector('#search-toggle .nav-link');
    expect(shortcutKeyElement.innerHTML).toBe('ctrl k');
  });

  test('should not throw error if shortcut key element is missing', () => {
    Object.defineProperty(navigator, 'platform', {
      value: 'MacIntel',
      configurable: true
    });

    document.body.innerHTML = `
      <div id="other-element"></div>
    `;

    loadScript();

    Object.defineProperty(document, 'readyState', {
      value: 'interactive',
      configurable: true
    });

    expect(() => {
      document.dispatchEvent(new Event('readystatechange'));
    }).not.toThrow();
  });

  test('should not update shortcut key if readyState is not interactive', () => {
    Object.defineProperty(navigator, 'platform', {
      value: 'MacIntel',
      configurable: true
    });

    document.body.innerHTML = `
      <div id="search-toggle">
        <a class="nav-link">ctrl k</a>
      </div>
    `;

    loadScript();

    Object.defineProperty(document, 'readyState', {
      value: 'complete',
      configurable: true
    });
    document.dispatchEvent(new Event('readystatechange'));

    const shortcutKeyElement = document.querySelector('#search-toggle .nav-link');
    expect(shortcutKeyElement.innerHTML).toBe('ctrl k');
  });
});
