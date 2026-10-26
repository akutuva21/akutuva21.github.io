describe("shortcut-key.js", () => {
  let originalPlatform;
  let originalReadyState;

  beforeAll(() => {
    originalPlatform = navigator.platform;
    originalReadyState = document.readyState;
  });

  afterAll(() => {
    Object.defineProperty(navigator, "platform", {
      value: originalPlatform,
      configurable: true,
    });
    Object.defineProperty(document, "readyState", {
      value: originalReadyState,
      configurable: true,
    });
  });

  beforeEach(() => {
    document.body.innerHTML = `
      <div id="search-toggle">
        <a class="nav-link">Original Text</a>
      </div>
    `;
    jest.resetModules();
  });

  const setPlatform = (platform) => {
    Object.defineProperty(navigator, "platform", {
      value: platform,
      configurable: true,
    });
  };

  const triggerReadyStateChange = (state) => {
    Object.defineProperty(document, "readyState", {
      value: state,
      configurable: true,
    });
    document.dispatchEvent(new Event("readystatechange"));
  };

  it("updates innerHTML if user is on a Mac and readyState is interactive", () => {
    setPlatform("MacIntel");
    require("./shortcut-key.js");

    triggerReadyStateChange("interactive");

    const element = document.querySelector("#search-toggle .nav-link");
    // jsdom decodes '&#x2318;' to '⌘'
    expect(element.innerHTML).toBe('⌘ k <i class="ti ti-search"></i>');
  });

  it("does not update innerHTML if user is on Windows", () => {
    setPlatform("Win32");
    require("./shortcut-key.js");

    triggerReadyStateChange("interactive");

    const element = document.querySelector("#search-toggle .nav-link");
    expect(element.innerHTML).toBe("Original Text");
  });

  it("does not update innerHTML if readyState is not interactive", () => {
    setPlatform("MacIntel");
    require("./shortcut-key.js");

    triggerReadyStateChange("complete");

    const element = document.querySelector("#search-toggle .nav-link");
    expect(element.innerHTML).toBe("Original Text");
  });

  it("does not throw error if the element is missing", () => {
    setPlatform("MacIntel");
    document.body.innerHTML = ""; // Remove element
    require("./shortcut-key.js");

    expect(() => {
      triggerReadyStateChange("interactive");
    }).not.toThrow();
  });
});
