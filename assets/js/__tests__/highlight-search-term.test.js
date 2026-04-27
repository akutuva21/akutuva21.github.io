/**
 * @jest-environment jsdom
 */

import { getTextNodesInElementContainingText } from '../highlight-search-term';

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

  it('should find a text node containing the exact search text', () => {
    container.innerHTML = '<p>Hello world</p>';
    const nodes = getTextNodesInElementContainingText(container, 'world');
    expect(nodes.length).toBe(1);
    expect(nodes[0].textContent).toBe('Hello world');
  });

  it('should be case-insensitive', () => {
    container.innerHTML = '<p>Hello World</p>';
    const nodes = getTextNodesInElementContainingText(container, 'world');
    expect(nodes.length).toBe(1);
    expect(nodes[0].textContent).toBe('Hello World');
  });

  it('should return multiple text nodes if they match', () => {
    container.innerHTML = '<div><p>Hello world</p><span>Cruel world</span></div>';
    const nodes = getTextNodesInElementContainingText(container, 'world');
    expect(nodes.length).toBe(2);
    expect(nodes[0].textContent).toBe('Hello world');
    expect(nodes[1].textContent).toBe('Cruel world');
  });

  it('should not return text nodes that do not match', () => {
    container.innerHTML = '<p>Hello universe</p>';
    const nodes = getTextNodesInElementContainingText(container, 'world');
    expect(nodes.length).toBe(0);
  });

  it('should ignore non-text nodes (like elements) but search their text node children', () => {
    container.innerHTML = '<div><span>Some text</span></div>';
    const nodes = getTextNodesInElementContainingText(container, 'text');
    expect(nodes.length).toBe(1);
    expect(nodes[0].nodeType).toBe(Node.TEXT_NODE);
    expect(nodes[0].textContent).toBe('Some text');
  });

  it('should handle deeply nested text nodes', () => {
    container.innerHTML = '<div><div><div><p>Deep down</p></div></div></div>';
    const nodes = getTextNodesInElementContainingText(container, 'down');
    expect(nodes.length).toBe(1);
    expect(nodes[0].textContent).toBe('Deep down');
  });

  it('should handle empty elements', () => {
    container.innerHTML = '<div></div>';
    const nodes = getTextNodesInElementContainingText(container, 'text');
    expect(nodes.length).toBe(0);
  });

  it('should handle search strings with spaces', () => {
    container.innerHTML = '<p>This is a test sentence</p>';
    const nodes = getTextNodesInElementContainingText(container, 'test sentence');
    expect(nodes.length).toBe(1);
    expect(nodes[0].textContent).toBe('This is a test sentence');
  });
});
