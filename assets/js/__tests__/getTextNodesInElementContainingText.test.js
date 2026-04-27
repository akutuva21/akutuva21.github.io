import { getTextNodesInElementContainingText } from '../highlight-search-term.js';

describe('getTextNodesInElementContainingText', () => {
  let container;

  beforeEach(() => {
    container = document.createElement('div');
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.removeChild(container);
    container = null;
  });

  test('finds text nodes containing the specific text', () => {
    container.innerHTML = '<div><p>Hello World</p><span>Other text</span><p>World Wide Web</p></div>';

    const nodes = getTextNodesInElementContainingText(container, 'world');

    expect(nodes.length).toBe(2);
    expect(nodes[0].textContent).toBe('Hello World');
    expect(nodes[1].textContent).toBe('World Wide Web');
  });

  test('is case insensitive', () => {
    container.innerHTML = '<div>Some text with uppercase MATCH</div>';

    const nodes = getTextNodesInElementContainingText(container, 'match');

    expect(nodes.length).toBe(1);
    expect(nodes[0].textContent).toBe('Some text with uppercase MATCH');
  });

  test('returns empty array if no matches found', () => {
    container.innerHTML = '<div><p>Hello World</p></div>';

    const nodes = getTextNodesInElementContainingText(container, 'missing');

    expect(nodes.length).toBe(0);
  });

  test('ignores element nodes, only finds text nodes', () => {
    container.innerHTML = '<div class="match">This doesn\'t have the word</div>';

    const nodes = getTextNodesInElementContainingText(container, 'match');

    expect(nodes.length).toBe(0);
  });

  test('handles empty text correctly', () => {
    container.innerHTML = '<div><p></p></div>';

    const nodes = getTextNodesInElementContainingText(container, 'text');

    expect(nodes.length).toBe(0);
  });
});
