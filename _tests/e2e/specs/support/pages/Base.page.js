export class Base {
    constructor({
                    path = '/',
                    pageTitle
                } = {}) {
        this.urlBase = process.env.RHD_BASE_URL;
        this.path = path;
        this.pageTitle = pageTitle;
        this.selectors = {};
    }

    open() {
        const openUrl = `${this.urlBase}${this.path}`;
        let res = this.visit(openUrl);

        if (this.pageTitle) {
            return this.waitForPageTitle(this.pageTitle, 30000);
        }
        return res;
    }

    addSelectors(selectors) {
        this.selectors = Object.assign(this.selectors, selectors);
    }

    getSelector(selectorName) {
        if (!this.selectors[selectorName]) {
            return console.log(`WARNING: ${selectorName} is not defined as page-object selector!`)
        }
        let selector = '';
        selector += this.selectors[selectorName];
        return selector.trim();
    }

    visit(url) {
        try {
            return browser.url(url);
        } catch (err) {
            if (err && err.message.indexOf('stale element reference') >= 0) {
                console.log('[safeIsVisible] Got stale element reference; trying again...');
                return  browser.url(url);
            }
        }
    }

    awaitIsLoggedIn(siteUser) {
        this.awaitIsNotVisible('.login', 60000) && this.awaitIsVisible('.logged-in', 60000);
        this.waitForSelectorContainingText('.logged-in-name', `${siteUser['firstName']} ${siteUser['lastName']}`, 60000);
    }

    waitForPageTitle(title, timeout = 10000) {
        browser.waitUntil(function () {
            return browser.getTitle().indexOf(title) > -1;
        }, timeout, `Timed out after ${timeout} seconds waiting for page title to contain ${title}`);
    }

    title() {
       return browser.getTitle();
    }

    waitForUrlContaining(string, timeout = 10000) {
        browser.waitUntil(function () {
            return browser.getUrl().indexOf(string) > -1
        }, timeout, `Timed out after ${timeout} seconds waiting for url to contain ${string}`);
    }

    waitForSelectorContainingText(selector, string, timeout = 10000) {
        browser.waitUntil(function () {
            return browser.getText(selector).indexOf(string) > -1;
        }, timeout, `Timed out after ${timeout} seconds waiting for selector to contain ${string}`);
    }

    element(selector) {
        let element = browser.element(selector);
        this.awaitExists(element);
        return element;
    }

    elements(selector) {
        let elements = browser.elements(selector);
        this.awaitExists(elements[0]);
        return elements;
    }

    displayed(selector) {
        this.awaitExists(selector);
        if (typeof selector === 'string') {
            return browser.isVisible(selector);
        } else {
            return selector.isVisible();
        }
    }

    awaitIsVisible(selector, timeout = 10000) {
        if (typeof selector === 'string') {
            browser.waitForVisible(selector, timeout);
            return true;
        } else {
            return selector.waitForVisible(timeout);
        }
    }

    awaitIsNotVisible(selector, timeout = 10000) {
        if (typeof selector === 'string') {
            return browser.waitForVisible(selector, timeout, true);
        } else {
            return selector.waitForVisible(timeout, true);
        }
    }

    type(input, selector) {
        this.awaitExists(selector);
        if (typeof selector === 'string') {
            return browser.setValue(selector, input);
        } else {
            return selector.setValue(input);
        }
    }

    clickOn(selector) {
        this.awaitExists(selector);
        if (typeof selector === 'string') {
            return browser.click(selector);
        } else {
            return selector.click();
        }
    }

    isSelected(selector) {
        if (typeof selector === 'string') {
            return browser.isSelected(selector);
        } else {
            return selector.isSelected();
        }
    }

    getValue(selector) {
        if (typeof selector === 'string') {
            return browser.getValue(selector);

        } else {
            return selector.getValue();
        }
    }

    selectByValue(selector, value) {
        this.awaitExists(selector);
        if (typeof selector === 'string') {
            browser.selectByValue(selector, value);
        } else {
            return selector.selectByValue(value);
        }
    }

    textOf(selector) {
        let text;
        this.awaitExists(selector);
        let i = 0;
        do {
            if (typeof selector === 'string') {
                text = browser.getText(selector);
            } else {
                text = selector.getText();
            }
            i++;
        }
        while (text === '' || i < 30);
        return text;
    }

    hasAlert() {
        let hasAlert;
        try {
            browser.alertText();
            hasAlert = true;
        } catch (e) {
            hasAlert = false;
        }
        return hasAlert;
    }

    key(key) {
        return browser.keys(key);
    }

    scrollIntoView(selector) {
        let location;
        if (typeof selector === 'string') {
            location = browser.getLocationInView(selector);
            return browser.scroll(location['x'], location['y']);
        } else {
            location = selector.getLocationInView();
            return selector.scroll(location['x'], location['y']);
        }
    }

    awaitExists(selector, timeout = 10000) {
        try {
            if (typeof selector === 'string') {
                return browser.waitForExist(selector, timeout);
            } else {
                return selector.waitForExist(timeout);
            }
        } catch (e) {
            return false;
        }
    }

    pageSource() {
        return browser.getSource();
    }
}
